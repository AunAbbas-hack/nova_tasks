import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';

/// Kaun sa global filter lagaa hua hai
enum HomeFilterSubset {
  all,       // Today + Overdue + Upcoming (grouped)
  overdue,   // Sirf overdue
  today,     // Sirf today
  upcoming,  // Sirf upcoming
}

class HomeViewModel extends ChangeNotifier {
  final TaskRepository repo;
  final String userId;

  StreamSubscription? _sub;

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  bool isLoading = true;

  // 🔹 Selected date (null => koi specific date nahi)
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  // 🔹 Category filter
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  // 🔹 Global mode (Show All bottom sheet ke options)
  HomeFilterSubset _subset = HomeFilterSubset.all;
  HomeFilterSubset get subset => _subset;

  // 🔹 Constructor
  HomeViewModel({required this.repo, required this.userId}) {
    // default: aaj ka din selected
    _selectedDate = _only(DateTime.now());
  }

  // -------------------------------------------------
  //  STREAM START / DISPOSE
  // -------------------------------------------------

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

  // -------------------------------------------------
  //  FILTER SETTERS
  // -------------------------------------------------

  /// Date chip tap hua
  void setSelectedDate(DateTime d) {
    _selectedDate = _only(d);
    // ✅ Date select hote hi hamesha All mode pe aa jao
    _subset = HomeFilterSubset.all;
    notifyListeners();
  }

  /// Same date dobara tap kare to clear (optional)
  void clearSelectedDate() {
    _selectedDate = null;
    notifyListeners();
  }

  /// Category chip tap
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Show All bottom sheet se koi option select
  void setSubset(HomeFilterSubset newSubset) {
    _subset = newSubset;
    notifyListeners();
  }

  bool get isFilteringAllCategory => _selectedCategory == 'All';

  // -------------------------------------------------
  //  AVAILABLE CATEGORIES
  // -------------------------------------------------

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

  // -------------------------------------------------
  //  CORE FILTER PIPELINE
  // -------------------------------------------------

  List<TaskModel> _baseFiltered() {
    return _tasks.where((t) {
      // Category filter
      if (_selectedCategory != 'All' &&
          t.category != _selectedCategory) {
        return false;
      }

      // Date filter (agar date selected hai)
      if (_selectedDate != null &&
          !_isSameDay(_only(t.date), _selectedDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  DateTime get _todayOnly => _only(DateTime.now());

  bool _isToday(TaskModel t) =>
      _isSameDay(_only(t.date), _todayOnly);

  bool _isOverdue(TaskModel t) {
    final d = _only(t.date);
    return d.isBefore(_todayOnly) && t.completedAt == null;
  }

  bool _isUpcoming(TaskModel t) =>
      _only(t.date).isAfter(_todayOnly);

  // -------------------------------------------------
  //  VIEW-SPECIFIC GETTERS
  // -------------------------------------------------

  /// 1) Jab koi date selected ho -> sirf us date ke tasks
  List<TaskModel> get dayTasks {
    // yahan hamesha selectedDate != null hota hoga
    return _baseFiltered();
  }

  /// 2) Today tasks (global / show-all view ke liye)
  List<TaskModel> get todayTasks {
    final base = _baseFiltered();
    return base.where(_isToday).toList();
  }

  /// 3) Overdue
  List<TaskModel> get overdueTasks {
    final base = _baseFiltered();
    return base.where(_isOverdue).toList();
  }

  /// 4) Upcoming (grouped by date)
  Map<DateTime, List<TaskModel>> get upcomingTasks {
    final base = _baseFiltered();
    final map = <DateTime, List<TaskModel>>{};

    for (final t in base) {
      if (_isUpcoming(t)) {
        final d = _only(t.date);
        map.putIfAbsent(d, () => []).add(t);
      }
    }

    // sort keys
    final sortedKeys = map.keys.toList()..sort();
    final ordered = <DateTime, List<TaskModel>>{};
    for (final k in sortedKeys) {
      ordered[k] = map[k]!;
    }
    return ordered;
  }

  /// 5) Flat list for Overdue/Today/Upcoming modes
  List<TaskModel> get currentFlatTasks {
    final base = _baseFiltered();

    switch (_subset) {
      case HomeFilterSubset.all:
        return base;
      case HomeFilterSubset.today:
        return base.where(_isToday).toList();
      case HomeFilterSubset.overdue:
        return base.where(_isOverdue).toList();
      case HomeFilterSubset.upcoming:
        return base.where(_isUpcoming).toList();
    }
  }

  // -------------------------------------------------
  //  TOGGLE COMPLETE
  // -------------------------------------------------

  Future<void> toggleComplete(TaskModel task) async {
    await repo.updateTask(task.userId, task.id, {
      "completedAt": task.completedAt == null ? DateTime.now() : null,
    });
  }

  // -------------------------------------------------
  //  RECURRENCE EXPANSION
  // -------------------------------------------------

  List<TaskModel> _expandRecurring(List<TaskModel> list) {
    final List<TaskModel> expanded = [];

    for (final task in list) {
      if (task.recurrenceRule == null) {
        expanded.add(task);
        continue;
      }

      // simple DAILY recurrence demo
      if (task.recurrenceRule == "DAILY") {
        for (int i = 0; i < 30; i++) {
          expanded.add(
            task.copyWith(
              date: _only(task.date.add(Duration(days: i))),
            ),
          );
        }
      } else {
        expanded.add(task);
      }
    }

    return expanded;
  }

  // -------------------------------------------------
  //  HELPERS
  // -------------------------------------------------

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _only(DateTime d) =>
      DateTime(d.year, d.month, d.day);
}

