import 'dart:async';

import 'package:flutter/material.dart';

class PasswordResetViewModel extends ChangeNotifier {
  PasswordResetViewModel() {
    newPasswordController.addListener(_notifyListeners);
    confirmPasswordController.addListener(_notifyListeners);
  }

  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Use at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> submit({
    required VoidCallback onSuccess,
    VoidCallback? onError,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _setSubmitting(true);
    try {
      // TODO: Integrate with backend password reset logic
      await Future.delayed(const Duration(milliseconds: 900));
      onSuccess();
    } catch (_) {
      onError?.call();
    } finally {
      _setSubmitting(false);
    }
  }

  double get passwordStrength {
    final password = newPasswordController.text;
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 8) score += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score += 0.3;
    return score.clamp(0, 1);
  }

  String get strengthLabel {
    final score = passwordStrength;
    if (score >= 0.8) return 'Strong';
    if (score >= 0.5) return 'Medium';
    if (score > 0) return 'Weak';
    return '';
  }

  Color get strengthColor {
    final score = passwordStrength;
    if (score >= 0.8) return const Color(0xFF38D39F);
    if (score >= 0.5) return const Color(0xFFFFC857);
    if (score > 0) return const Color(0xFFFF5A5A);
    return const Color(0xFF2E3A4A);
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting == value) return;
    _isSubmitting = value;
    notifyListeners();
  }

  void _notifyListeners() => notifyListeners();

  @override
  void dispose() {
    newPasswordController.removeListener(_notifyListeners);
    confirmPasswordController.removeListener(_notifyListeners);
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
