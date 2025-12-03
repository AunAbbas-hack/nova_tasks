import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? emailError;
  String? passwordError;
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
     // Send Verification Email
      // 3) callback
      onSuccess();
    }on FirebaseAuthException catch (e) {
      onError?.call();
      switch (e.code) {
        case "user-not-found":
          emailError = "No account found with this email";
          break;
        case "email-already-in-use":
          emailError = "Email already in use";
          break;
        case "weak-password":
          passwordError = "Password must be at least 6 characters";
          break;
        case "wrong-password":
          passwordError = "Incorrect password";
          break;

        case "invalid-email":
          emailError = "Invalid email format";
          break;


      }
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> signUpWithGoogle({
    required VoidCallback onSuccess,
    VoidCallback? onError,
  }) async {
    final googleSign=GoogleSignIn.instance;
    unawaited(
      googleSign.initialize(clientId: "75231049160")
    );
    try {
      _setSubmitting(true);

      // Define scopes
      const scopes = [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid',
      ];

      // Authenticate with scopes

      final GoogleSignInAccount? googleUser =
      await GoogleSignIn.instance.authenticate(
        scopeHint: scopes,
      );

      if (googleUser == null) {
        _setSubmitting(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCred =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCred.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      onSuccess();

    } catch (e) {
      debugPrint('Google Sign-Up Error: $e');
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
