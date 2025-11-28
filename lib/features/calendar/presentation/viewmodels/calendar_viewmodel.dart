import 'dart:async';
import 'package:flutter/material.dart';
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
    for (final t in _tasks) {
      final key = _only(t.date);
      _tasksByDate.putIfAbsent(key, () => []).add(t);
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

  bool isSameDayInternal(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
