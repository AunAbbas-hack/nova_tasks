import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel({
    required this.repo,
    required this.userId,
  }) {
    _start();
  }

  final TaskRepository repo;
  final String userId;

  StreamSubscription<List<TaskModel>>? _sub;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  /// Grouped by normalized day
  final Map<DateTime, List<TaskModel>> _tasksByDate = {};

  DateTime _focusedDay = _only(DateTime.now());
  DateTime get focusedDay => _focusedDay;

  DateTime? _selectedDay = _only(DateTime.now());
  DateTime? get selectedDay => _selectedDay;

  DateTime? _rangeStart;
  DateTime? get rangeStart => _rangeStart;

  DateTime? _rangeEnd;
  DateTime? get rangeEnd => _rangeEnd;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  RangeSelectionMode get rangeSelectionMode => _rangeSelectionMode;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  CalendarFormat get calendarFormat => _calendarFormat;

  // ------------------- INIT / DISPOSE -------------------

  void _start() {
    _sub = repo.streamUserTasks(userId).listen((list) {
      _tasks = list;
      _rebuildByDate();
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ------------------- GROUPING -------------------

  void _rebuildByDate() {
    _tasksByDate.clear();
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 365)); // Look ahead 1 year

    for (final task in _tasks) {
      // Always include the original task date
      _addTaskToDate(task, task.date);

      // Handle recurring tasks
      if (task.recurrenceRule?.isNotEmpty == true) {
        final start = _only(task.date);
        DateTime current = start.add(const Duration(days: 1)); // Start from next day
        int count = 0;
        
        // Generate up to 1000 occurrences or until maxDate
        while (current.isBefore(maxDate) && count < 1000) {
          if (_occursOn(task, current)) {
            _addTaskToDate(task, current);
          }
          current = current.add(const Duration(days: 1));
          count++;
        }
      }
    }
  }

  void _addTaskToDate(TaskModel task, DateTime date) {
    final key = _only(date);
    _tasksByDate.putIfAbsent(key, () => []).add(task);
  }

  bool _occursOn(TaskModel task, DateTime day) {
    final dayOnly = _only(day);
    final start = _only(task.date);
    final rule = task.recurrenceRule?.trim();

    if (rule == null || rule.isEmpty || dayOnly.isBefore(start)) {
      return _isSameDay(start, dayOnly);
    }

    final parts = rule.split(';').map((e) => e.split('=')).toList();
    final frequency = parts.firstWhereOrNull((e) => e[0] == 'F')?[1];
    final until = parts.firstWhereOrNull((e) => e[0] == 'UNTIL');
    final count = parts.firstWhereOrNull((e) => e[0] == 'COUNT');

    if (until != null) {
      final untilDate = DateTime.parse(until[1]);
      if (dayOnly.isAfter(_only(untilDate))) {
        return false;
      }
    }

    if (count != null) {
      final maxOccurrences = int.tryParse(count[1]) ?? 0;
      if (maxOccurrences > 0) {
        int occurrences = 0;
        DateTime current = start;
        while (!current.isAfter(dayOnly) && occurrences <= maxOccurrences) {
          if (_matchesRecurrencePattern(task, current, frequency, parts)) {
            occurrences++;
            if (_isSameDay(current, dayOnly)) {
              return true;
            }
            if (occurrences >= maxOccurrences) {
              return false;
            }
          }
          current = current.add(const Duration(days: 1));
        }
        return false;
      }
    }

    return _matchesRecurrencePattern(task, dayOnly, frequency, parts);
  }

  bool _matchesRecurrencePattern(TaskModel task, DateTime day, String? frequency, List<List<String>> parts) {
    final start = _only(task.date);
    if (_isSameDay(start, day)) return true;

    switch (frequency) {
      case 'DAILY':
        return true;
      case 'WEEKLY':
        final byDay = parts.firstWhereOrNull((e) => e[0] == 'BYDAY');
        if (byDay != null) {
          final weekDays = byDay[1].split(',').map(int.parse).toSet();
          return weekDays.contains(day.weekday);
        }
        return day.weekday == start.weekday;
      case 'MONTHLY':
        return day.day == start.day;
      case 'YEARLY':
        return day.month == start.month && day.day == start.day;
      default:
        return _isSameDay(start, day);
    }
  }

  List<TaskModel> getTasksForDay(DateTime day) {
    final key = _only(day);
    final list = _tasksByDate[key] ?? [];
    final sorted = [...list]..sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  List<TaskModel> getTasksForRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return [];
    final s = _only(start);
    final e = _only(end);

    final result = _tasks.where((t) {
      final d = _only(t.date);
      final afterStart = !d.isBefore(s); // d >= s
      final beforeEnd = !d.isAfter(e);   // d <= e
      return afterStart && beforeEnd;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return result;
  }

  List<TaskModel> get visibleTasks {
    if (_rangeSelectionMode == RangeSelectionMode.toggledOn &&
        _rangeStart != null &&
        _rangeEnd != null) {
      return getTasksForRange(_rangeStart, _rangeEnd);
    }
    return getTasksForDay(_selectedDay ?? _focusedDay);
  }

  int get visibleTasksCount => visibleTasks.length;

  bool get isRangeActive =>
      _rangeSelectionMode == RangeSelectionMode.toggledOn &&
          _rangeStart != null &&
          _rangeEnd != null;

  // ------------------- TABLE CALENDAR HANDLERS -------------------

  void onDaySelected(DateTime selected, DateTime focused) {
    _selectedDay = _only(selected);
    _focusedDay = focused;
    _rangeStart = null;
    _rangeEnd = null;
    _rangeSelectionMode = RangeSelectionMode.toggledOff;
    notifyListeners();
  }

  void onRangeSelected(
      DateTime? start,
      DateTime? end,
      DateTime focused,
      ) {
    _selectedDay = null;
    _focusedDay = focused;
    _rangeStart = start != null ? _only(start) : null;
    _rangeEnd = end != null ? _only(end) : null;
    _rangeSelectionMode = RangeSelectionMode.toggledOn;
    notifyListeners();
  }

  void onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      _calendarFormat = format;
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focused) {
    _focusedDay = focused;
  }

  // ------------------- TASK ACTIONS -------------------

  Future<void> toggleComplete(TaskModel task) async {
    final newCompletedAt = task.completedAt == null ? DateTime.now() : null;

    // Optimistic update in local list
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      final updated = task.copyWith(completedAt: newCompletedAt);
      _tasks[idx] = updated;
      _rebuildByDate();
      notifyListeners();
    }

    await repo.updateTask(
      task.userId,
      task.id,
      {'completedAt': newCompletedAt},
    );
  }

  // ------------------- HELPERS -------------------

  static DateTime _only(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool _isSameDay(DateTime a, DateTime b) => 
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isSameDayInternal(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
