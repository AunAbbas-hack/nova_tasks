import 'dart:async';

import 'package:flutter/material.dart';

class OtpViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
    growable: false,
  );

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? validateDigits(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    if (value.length != 1 || int.tryParse(value) == null) {
      return '';
    }
    return null;
  }

  String get otpCode =>
      codeControllers.map((controller) => controller.text).join();

  Future<void> verifyCode({
    required VoidCallback onSuccess,
    VoidCallback? onError,
  }) async {
    if (!_isCodeComplete()) {
      onError?.call();
      return;
    }
    _setSubmitting(true);
    try {
      // TODO: Connect to backend OTP verification
      await Future.delayed(const Duration(milliseconds: 800));
      onSuccess();
    } catch (_) {
      onError?.call();
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> resendCode({
    required VoidCallback onSuccess,
    VoidCallback? onError,
  }) async {
    try {
      // TODO: Trigger resend logic
      await Future.delayed(const Duration(milliseconds: 800));
      onSuccess();
    } catch (_) {
      onError?.call();
    }
  }

  bool _isCodeComplete() {
    return codeControllers.every((controller) => controller.text.length == 1);
  }

  void _setSubmitting(bool value) {
    if (_isSubmitting == value) return;
    _isSubmitting = value;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controller in codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}


