import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nova_tasks/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? emailError;
  String? passwordError;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // ---------------- VALIDATION ----------------

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

  // ---------------- LOGIN FLOW ----------------

  Future<void> submit({
    required VoidCallback onSuccess,
    VoidCallback? onError,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _setSubmitting(true);
    emailError = null;
    passwordError = null;

    try {
      await _authRepository.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loggedIn", true);

      onSuccess();
    } on FirebaseAuthException catch (e) {
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
        default:
          passwordError = e.message ?? "Login failed";
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

  // ---------------- STATE MGMT ----------------

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
