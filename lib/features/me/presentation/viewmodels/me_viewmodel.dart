import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';

class MeViewModel extends ChangeNotifier {
  MeViewModel({
    required this.repo,
    required this.userId,
  }) {
    _init();
  }

  final TaskRepository repo;
  final String userId;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  StreamSubscription<List<TaskModel>>? _sub;
  List<TaskModel> _tasks = [];
  bool isLoading = true;

  /// Local picked image (for instant UI update)
  File? profileImageFile;

  /// Remote Firebase hosted image URL
  String? profileImageUrl;

  User? _user;

  // ---------------------- GETTERS ----------------------

  String get name => _user?.displayName ?? "Guest User";

  String get email => _user?.email ?? "no-email";

  // Tasks Stats
  int get totalTasks => _tasks.length;

  int get tasksCompleted =>
      _tasks.where((t) => t.completedAt != null).length;

  int get onTimeRate {
    if (totalTasks == 0) return 0;
    return ((tasksCompleted / totalTasks) * 100).round();
  }

  int get currentStreak => _calculateStreak();

  // ---------------------- INITIALIZATION ----------------------

  Future<void> _init() async {
    _user = _auth.currentUser;

    // Load Firestore user profile
    await _loadProfileFromFirestore();

    // Listen for tasks
    _sub = repo.streamUserTasks(userId).listen((list) {
      _tasks = list;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadProfileFromFirestore() async {
    final doc = await _db.collection('users').doc(userId).get();

    if (doc.exists) {
      final data = doc.data()!;
      profileImageUrl = data['photoUrl'];
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ---------------------- UPDATE NAME ----------------------

  Future<void> updateName(String newName) async {
    final n = newName.trim();
    if (n.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    // FirebaseAuth update
    await user.updateDisplayName(n);
    await user.reload();
    _user = _auth.currentUser;

    // Firestore update
    await _db.collection("users").doc(userId).set(
      {"name": n},
      SetOptions(merge: true),
    );

    notifyListeners();
  }

  // ---------------------- PROFILE IMAGE PICK + UPLOAD ----------------------

  Future<void> pickProfileImage() async {
    try {
      final picker = ImagePicker();

      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (picked == null) return;

      // Local file for instant UI update
      profileImageFile = File(picked.path);
      notifyListeners();

      // Upload to Firebase Storage
      final ref = _storage.ref()
          .child("profile_images")
          .child("$userId.jpg");

      await ref.putFile(profileImageFile!);

      // Get download URL
      final url = await ref.getDownloadURL();
      profileImageUrl = url;

      // Save to Firestore
      await _db.collection("users").doc(userId).set(
        {"photoUrl": url},
        SetOptions(merge: true),
      );

      // Update FirebaseAuth photo URL
      await _auth.currentUser?.updatePhotoURL(url);

      notifyListeners();
    } catch (e) {
      debugPrint("ERROR picking/uploading image: $e");
    }
  }

  // ---------------------- STREAK CALCULATION ----------------------

  int _calculateStreak() {
    final completedDates = _tasks
        .where((t) => t.completedAt != null)
        .map((t) => DateTime(t.completedAt!.year,
        t.completedAt!.month, t.completedAt!.day))
        .toSet();

    if (completedDates.isEmpty) return 0;

    int streak = 0;
    var cursor = DateTime.now();

    while (completedDates.contains(DateTime(
      cursor.year,
      cursor.month,
      cursor.day,
    ))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
