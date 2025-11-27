// lib/features/home/presentation/viewmodels/home_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final TaskRepository repo;
  final String userId;

  StreamSubscription? _sub;

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  bool isLoading = true;

  DateTime _selectedDate = _only(DateTime.now());
  DateTime get selectedDate => _selectedDate;

  // 🔹 Category filter state
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  // Categories available from tasks
  List<String> get availableCategories {
    final set = <String>{};
    for (final t in _tasks) {
      if (t.category.trim().isNotEmpty) {
        set.add(t.category);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  HomeViewModel({required this.repo, required this.userId});

  // ---------------- START REAL-TIME LISTENER ----------------

  void start() {
    _sub = repo.streamUserTasks(userId).listen((list) {
      _tasks = _expandRecurring(list);
      isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ---------------- DATE SELECTOR ----------------

  void setSelectedDate(DateTime d) {
    _selectedDate = _only(d);
    notifyListeners();
  }

  // ---------------- CATEGORY SELECTOR ----------------

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  bool get isFilteringAll => _selectedCategory == 'All';

  // ---------------- FILTERED LIST HELPERS ----------------

  List<TaskModel> _byCategory(List<TaskModel> source) {
    if (_selectedCategory == 'All') return source;
    return source.where((t) => t.category == _selectedCategory).toList();
  }

  // ---------------- GROUPED VIEWS ----------------

  List<TaskModel> get todayTasks {
    final source =
    _tasks.where((t) => _isSameDay(t.date, _selectedDate)).toList();
    return _byCategory(source);
  }

  List<TaskModel> get overdueTasks {
    final today = _only(DateTime.now());
    final source = _tasks.where((t) {
      final d = _only(t.date);
      return d.isBefore(today) && t.completedAt == null;
    }).toList();
    return _byCategory(source);
  }

  Map<DateTime, List<TaskModel>> get upcomingTasks {
    final today = _only(DateTime.now());
    final map = <DateTime, List<TaskModel>>{};

    for (final t in _tasks) {
      final d = _only(t.date);
      if (d.isAfter(today)) {
        map.putIfAbsent(d, () => []).add(t);
      }
    }

    // category filter apply per date bucket
    final filtered = <DateTime, List<TaskModel>>{};
    final sortedKeys = map.keys.toList()..sort();

    for (final date in sortedKeys) {
      final list = _byCategory(map[date]!);
      if (list.isNotEmpty) {
        filtered[date] = list;
      }
    }

    return filtered;
  }

  // ---------------- TOGGLE COMPLETE ----------------

  Future<void> toggleComplete(TaskModel task) async {
    await repo.updateTask(task.userId, task.id, {
      "completedAt": task.completedAt == null ? DateTime.now() : null,
    });
  }

  // ---------------- RECURRENCE LOGIC ----------------

  List<TaskModel> _expandRecurring(List<TaskModel> list) {
    final List<TaskModel> expanded = [];

    for (final task in list) {
      if (task.recurrenceRule == null) {
        expanded.add(task);
        continue;
      }

      // Simple DAILY recurrence example
      if (task.recurrenceRule == "DAILY") {
        for (int i = 0; i < 30; i++) {
          expanded.add(
            task.copyWith(
              date: _only(task.date.add(Duration(days: i))),
            ),
          );
        }
      } else {
        // other rules future
        expanded.add(task);
      }
    }

    return expanded;
  }

  // ---------------- HELPERS ----------------

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _only(DateTime d) =>
      DateTime(d.year, d.month, d.day);
}
