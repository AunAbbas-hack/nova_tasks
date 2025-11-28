import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  StreamSubscription<List<TaskModel>>? _sub;
  List<TaskModel> _tasks = [];
  bool isLoading = true;

  User? _user;

  // --------- USER INFO ---------

  String get name => _user?.displayName?.trim().isNotEmpty == true
      ? _user!.displayName!
      : 'Guest User';

  String get email => _user?.email ?? 'no-email';

  // --------- STATS ---------

  int get totalTasks => _tasks.length;

  int get tasksCompleted =>
      _tasks.where((t) => t.completedAt != null).length;

  int get onTimeRate {
    if (totalTasks == 0) return 0;
    return ((tasksCompleted / totalTasks) * 100).round();
  }

  int get currentStreak => _calculateStreak();

  // --------- INIT / DISPOSE ---------

  void _init() {
    _user = _auth.currentUser;

    _sub = repo.streamUserTasks(userId).listen((list) {
      _tasks = list;
      isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // --------- ACTIONS ---------

  Future<void> updateName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(trimmed);
    await user.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  // (Email change in Firebase usually needs re-auth, so abhi sirf display ke
  //  liye rakhtay hain – nahi chhedte.)

  // --------- HELPERS ---------

  int _calculateStreak() {
    if (_tasks.isEmpty) return 0;

    final completedDates = _tasks
        .where((t) => t.completedAt != null)
        .map(
          (t) => DateTime(
        t.completedAt!.year,
        t.completedAt!.month,
        t.completedAt!.day,
      ),
    )
        .toSet();

    if (completedDates.isEmpty) return 0;

    int streak = 0;
    var cursor = DateTime.now();
    while (true) {
      final d = DateTime(cursor.year, cursor.month, cursor.day);
      if (completedDates.contains(d)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
