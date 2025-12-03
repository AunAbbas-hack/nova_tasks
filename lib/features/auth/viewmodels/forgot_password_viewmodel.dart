import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nova_tasks/data/datasources/remote/firebase_auth_source.dart';

import 'package:nova_tasks/data/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _lastSubmittedEmail;
  String? get lastSubmittedEmail => _lastSubmittedEmail;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> sendVerificationCode({
    required ValueChanged<String> onSuccess,
    VoidCallback? onError,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    _setSubmitting(true);
    try {
      await _authRepository.sendPasswordResetEmail(email);
      _lastSubmittedEmail = email;
      onSuccess(email);
    } catch (_) {
      onError?.call();
    } finally {
      _setSubmitting(false);
    }
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting == value) return;
    _isSubmitting = value;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
