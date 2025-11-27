import 'dart:async';

import 'package:flutter/material.dart';

import 'package:nova_tasks/data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> submit({
    required VoidCallback onSuccess,
    required VoidCallback onProgress,
    VoidCallback? onError,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _setSubmitting(true);


    try {
      await _authRepository.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      onProgress();
      onSuccess();
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
    passwordController.dispose();
    super.dispose();
  }
}
