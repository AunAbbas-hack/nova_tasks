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

  HomeViewModel({required this.repo, required this.userId}) {
    // default: aaj ka din selected
    _selectedDate = _only(DateTime.now());
  }

  // -------------------------------------------------
  //  STREAM START / DISPOSE
  // -------------------------------------------------

  void start() {
    _sub = repo.streamUserTasks(userId).listen((list) {
      _tasks = list; // ✅ ab hum expandRecurring nahi kar rahe
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
  //  BASIC HELPERS
  // -------------------------------------------------

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _only(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  DateTime get _todayOnly => _only(DateTime.now());

  bool _isRecurring(TaskModel t) =>
      (t.recurrenceRule?.trim().isNotEmpty ?? false);

  /// Recurrence rule ko dekh kar decide karta hai ke *is day* pe yeh task aata hai ya nahi
  bool _occursOn(TaskModel task, DateTime day) {
    final dayOnly = _only(day);
    final start = _only(task.date);
    final rule = task.recurrenceRule?.trim();

    // agar recurrence hi nahi → simple one-time task
    if (rule == null || rule.isEmpty) {
      return _isSameDay(start, dayOnly);
    }

    // future recurrence ke liye: start se pehle walon pe mat dikhao
    if (dayOnly.isBefore(start)) return false;

    // DAILY
    if (rule == 'DAILY') {
      return true;
    }

    // WEEKLY:1,3,5  (1=Mon ... 7=Sun)
    if (rule.startsWith('WEEKLY:')) {
      final part = rule.substring('WEEKLY:'.length);
      final days = part
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toSet();
      return days.contains(dayOnly.weekday);
    }

    // MONTHLY:15
    if (rule.startsWith('MONTHLY:')) {
      final part = rule.substring('MONTHLY:'.length);
      final dom = int.tryParse(part.trim());
      if (dom == null) return false;
      return dayOnly.day == dom;
    }

    // unknown rule → fallback: sirf start date
    return _isSameDay(start, dayOnly);
  }

  /// 24h + 12h (AM/PM) dono time formats ko parse karta hai
  DateTime _parseTaskDateTime(DateTime baseDate, String timeStr) {
    timeStr = timeStr.trim();

    int hour = 23;
    int minute = 59;

    // 12h format?  e.g. "2:30 PM"
    final amPmRegex =
    RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
    final amPmMatch = amPmRegex.firstMatch(timeStr);

    if (amPmMatch != null) {
      hour = int.parse(amPmMatch.group(1)!);
      minute = int.parse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!.toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
    } else {
      // assume 24h HH:mm
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        hour = int.tryParse(parts[0]) ?? 23;
        minute = int.tryParse(parts[1]) ?? 59;
      }
    }

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );
  }

  // -------------------------------------------------
  //  FILTER SETTERS
  // -------------------------------------------------

  /// Date chip tap hua
  void setSelectedDate(DateTime d) {
    _selectedDate = _only(d);
    // date select hone par subset as-is rehne do
    notifyListeners();
  }

  void clearSelectedDate() {
    _selectedDate = null;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSubset(HomeFilterSubset newSubset) {
    _subset = newSubset;

    // Show All ke filters lagate waqt date/category reset
    _selectedDate = null;
    _selectedCategory = 'All';

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
  //  CORE FILTER PIPELINE (category + date)
  // -------------------------------------------------

  List<TaskModel> _baseFiltered() {
    return _tasks.where((t) {
      // Category filter
      if (_selectedCategory != 'All' && t.category != _selectedCategory) {
        return false;
      }

      // Date filter (agar date selected hai, recurrence aware)
      if (_selectedDate != null && !_occursOn(t, _selectedDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  // -------------------------------------------------
  //  STATUS HELPERS (Today / Overdue / Upcoming)
  // -------------------------------------------------

  bool _isToday(TaskModel t) {
    final today = _todayOnly;
    return _occursOn(t, today);
  }

  /// Non-recurring tasks ke liye date + time based overdue
  bool _isTaskOverdue(TaskModel t) {
    if (t.completedAt != null) return false;
    if (_isRecurring(t)) return false; // ✅ recurring ko overdue nahi dikha rahe

    final now = DateTime.now();
    final today = _todayOnly;
    final taskDay = _only(t.date);

    // Date pehle ka → overdue
    if (taskDay.isBefore(today)) return true;

    // Future date → overdue nahi
    if (taskDay.isAfter(today)) return false;

    // same day, time check
    if (t.time.trim().isEmpty) return false;

    final due = _parseTaskDateTime(t.date, t.time);
    return now.isAfter(due);
  }

  /// Non-recurring upcoming helper
  bool _isUpcomingNonRecurring(TaskModel t) {
    final now = DateTime.now();
    final today = _todayOnly;
    final d = _only(t.date);

    if (d.isAfter(today)) return true;

    if (_isSameDay(d, today)) {
      if (t.time.trim().isEmpty) return false;
      final due = _parseTaskDateTime(t.date, t.time);
      return due.isAfter(now);
    }

    return false;
  }

  /// Recurring ke liye: kya aaj ke baad next 90 din me koi occurrence aati hai?
  bool _isUpcomingRecurring(TaskModel t) {
    if (!_isRecurring(t)) return false;

    final today = _todayOnly;
    for (int i = 1; i <= 90; i++) {
      final d = today.add(Duration(days: i));
      if (_occursOn(t, d)) return true;
    }
    return false;
  }

  bool _isUpcoming(TaskModel t) {
    if (_isRecurring(t)) {
      return _isUpcomingRecurring(t);
    }
    return _isUpcomingNonRecurring(t);
  }

  // -------------------------------------------------
  //  VIEW-SPECIFIC GETTERS
  // -------------------------------------------------

  /// 1) Jab koi date selected ho -> sirf us date ke tasks (recurrence aware)
  List<TaskModel> get dayTasks {
    if (_selectedDate == null) return [];
    final base = _baseFiltered();
    // _baseFiltered already respects selectedDate + category
    return base;
  }

  /// 2) Today tasks (global/show-all view)
  List<TaskModel> get todayTasks {
    final base = _baseFiltered().where((t) => _occursOn(t, _todayOnly)).toList();
    return base;
  }

  /// 3) Overdue (sirf non-recurring)
  List<TaskModel> get overdueTasks {
    final base = _baseFiltered();
    return base.where(_isTaskOverdue).toList();
  }

  /// 4) Upcoming (grouped by date, recurring + non-recurring)
  Map<DateTime, List<TaskModel>> get upcomingTasks {
    final base = _baseFiltered();
    final map = <DateTime, List<TaskModel>>{};
    final today = _todayOnly;

    for (final t in base) {
      if (_isRecurring(t)) {
        // next 30 days me jitne occurrences hain (aaj ko skip)
        for (int i = 1; i <= 30; i++) {
          final d = _only(today.add(Duration(days: i)));
          if (_occursOn(t, d)) {
            map.putIfAbsent(d, () => []).add(t);
          }
        }
      } else {
        if (_isUpcomingNonRecurring(t)) {
          final d = _only(t.date);
          if (!_isSameDay(d, today)) {
            map.putIfAbsent(d, () => []).add(t);
          }
        }
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

  /// 5) Flat list for Overdue/Today/Upcoming modes (Show All tab)
  List<TaskModel> get currentFlatTasks {
    final base = _baseFiltered();

    switch (_subset) {
      case HomeFilterSubset.all:
        return base;
      case HomeFilterSubset.today:
        return base.where(_isToday).toList();
      case HomeFilterSubset.overdue:
        return base.where(_isTaskOverdue).toList();
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
}
