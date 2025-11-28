import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nova_tasks/data/repositories/auth_repository.dart';

class SignupViewModel extends ChangeNotifier {
  SignupViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // ------------ validators ------------

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Enter at least 3 characters';
    }
    return null;
  }

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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ------------ submit / sign up ------------

  Future<void> submit({
    required VoidCallback onSuccess,
    VoidCallback? onError,
  }) async {
    // form validation
    if (!(formKey.currentState?.validate() ?? false)) return;

    _setSubmitting(true);
    try {
      // 1) sign up via repository
      await _authRepository.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2) update displayName in FirebaseAuth
      final user = FirebaseAuth.instance.currentUser;
      final name = nameController.text.trim();

      if (user != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload(); // taake turant reflect ho
      }

      // 3) callback
      onSuccess();
    } catch (e) {
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
