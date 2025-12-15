import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';

/// Global "Show all" filter (bottom sheet)
enum HomeFilterSubset {
  all,       // Today + Overdue + Upcoming (grouped)
  overdue,   // Only overdue
  today,     // Only today
  upcoming,  // Only upcoming
}

class HomeViewModel extends ChangeNotifier {
  final TaskRepository repo;
  final String userId;

  StreamSubscription? _sub;

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  /// Completed tasks (those with a non-null completedAt or recurring tasks with completed dates)
  /// If a date is selected, only shows completed tasks for that specific date
  List<TaskModel> get completedTasks {
    final List<TaskModel> completed = [];
    
    for (final t in _tasks) {
      if (_isRecurring(t)) {
        // For recurring tasks, check completedDates
        if (_selectedDate != null) {
          // If date is selected, only show if this specific date is completed
          final dateOnly = _only(_selectedDate!);
          final isDateCompleted = t.completedDates.any((d) => _isSameDay(d, dateOnly));
          if (isDateCompleted) {
            // Create a "virtual" task for this specific completed occurrence
            completed.add(t.copyWith(
              completedAt: dateOnly,
              date: dateOnly,
            ));
          }
        } else {
          // If no date selected, show all completed occurrences
          if (t.completedDates.isNotEmpty) {
            for (final completedDate in t.completedDates) {
              completed.add(t.copyWith(
                completedAt: completedDate,
                date: completedDate,
              ));
            }
          }
        }
      } else {
        // For non-recurring tasks, check completedAt
        if (t.completedAt != null) {
          if (_selectedDate != null) {
            // If date is selected, only show if completed on that date
            final dateOnly = _only(_selectedDate!);
            final completedDateOnly = _only(t.completedAt!);
            if (_isSameDay(completedDateOnly, dateOnly)) {
              completed.add(t);
            }
          } else {
            // If no date selected, show all completed tasks
            completed.add(t);
          }
        }
      }
    }
    
    // Sort completed tasks by their completion date (most recent first)
    completed.sort((a, b) => (b.completedAt ?? DateTime(0)).compareTo(a.completedAt ?? DateTime(0)));
    return completed;
  }

  bool isLoading = true;

  // -------- Selected Date (null => no specific date filter) --------
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  // -------- Category filter --------
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  // -------- Show All subset --------
  HomeFilterSubset _subset = HomeFilterSubset.all;
  HomeFilterSubset get subset => _subset;

  HomeViewModel({required this.repo, required this.userId}) {
    // Default: today selected
    _selectedDate = _only(DateTime.now());
  }

  // -------------------------------------------------
  //  STREAM START / DISPOSE
  // -------------------------------------------------

  void start() {
    _sub = repo.streamUserTasks(userId).listen((list) {
      list.sort((a, b) {
        final d1=DateTime(a.date.year,a.date.month,a.date.day);
        final d2=DateTime(b.date.year,b.date.month,b.date.day);
        final dateCompare=d1.compareTo(d2);
        if(dateCompare!=0){
          return dateCompare;
        }
        final t1=_parseTaskDateTime(a.date, a.time);
        final t2=_parseTaskDateTime(b.date, b.time);
        return t1.compareTo(t2);
      });

      _tasks = list; // recurrence is handled logically, not expanded
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

  /// Public helper for UI
  bool isRecurring(TaskModel t) => _isRecurring(t);

bool _occursOn(TaskModel task, DateTime day) {
  try {
    final dayOnly = _only(day);
    final start = _only(task.date);
    final rule = task.recurrenceRule?.trim();

    // No recurrence → single instance
    if (rule == null || rule.isEmpty) {
      return _isSameDay(start, dayOnly);
    }

    // Do not show before start date
    if (dayOnly.isBefore(start)) return false;

    // Parse the recurrence rule
    final parts = rule.split(';').map((e) => e.split('=')).toList();
    final frequency = parts.firstWhereOrNull((e) => e[0] == 'F')?[1];
    final until = parts.firstWhereOrNull((e) => e[0] == 'UNTIL');
    final count = parts.firstWhereOrNull((e) => e[0] == 'COUNT');

    // Check end conditions
    if (until != null && until.length > 1) {
      try {
        String dateStr = until[1];
        DateTime untilDate;

        // Try parsing with different formats
        try {
          // First try parsing directly
          untilDate = DateTime.parse(dateStr);
        } catch (_) {
          // If direct parsing fails, try handling YYYY-MM-DD format
          final dateParts = dateStr.split('-');
          if (dateParts.length == 3) {
            final year = int.tryParse(dateParts[0]) ?? 0;
            final month = int.tryParse(dateParts[1]) ?? 1;
            final day = int.tryParse(dateParts[2]) ?? 1;
            untilDate = DateTime(year, month, day);
          } else {
            // If all parsing fails, assume no end date
            debugPrint('Could not parse UNTIL date: $dateStr');
            return true;
          }
        }

        if (dayOnly.isAfter(_only(untilDate))) {
          return false;
        }
      } catch (e) {
        debugPrint('Error in UNTIL date handling: $e');
        // If we can't parse the until date, assume the task should be shown
        return true;
      }
    }

    if (count != null && count.length > 1) {
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
  } catch (e) {
    debugPrint('Error in _occursOn for task ${task.id}: $e');
    // If there's any error, show the task to avoid hiding it due to a parsing error
    return true;
  }
}

  bool _matchesRecurrencePattern(TaskModel task, DateTime day, String? frequency, List<List<String>> parts) {
    final start = _only(task.date);

    // If it's the start date, it should always be included
    if (_isSameDay(start, day)) {
      return true;
    }

    // Check if the day matches the frequency pattern
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

  /// 24h + 12h (AM/PM) dono time formats ko parse karta hai
  DateTime _parseTaskDateTime(DateTime baseDate, String timeStr) {
    timeStr = timeStr.trim();

    int hour = 23;
    int minute = 59;

    // 12h format e.g. "2:30 PM"
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

  /// Show All bottom sheet se subset select
  void setSubset(HomeFilterSubset newSubset) {
    _subset = newSubset;
    // Global filters pe aate waqt date/category reset
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
    // Core pipeline only works on *active* (incomplete) tasks.
    // Completed tasks are shown separately in the UI dropdown.
    // For recurring tasks, check if the specific date is completed
    final active = _tasks.where((t) {
      if (_isRecurring(t)) {
        // For recurring tasks, check if the current date is in completedDates
        if (_selectedDate != null) {
          final dateOnly = _only(_selectedDate!);
          return !t.completedDates.any((d) => _isSameDay(d, dateOnly));
        }
        // If no date selected, show if not all dates are completed (check original date)
        final dateOnly = _only(t.date);
        return !t.completedDates.any((d) => _isSameDay(d, dateOnly));
      }
      return t.completedAt == null;
    }).toList();

    return active.where((t) {
      // Category filter
      if (_selectedCategory != 'All' && t.category != _selectedCategory) {
        return false;
      }

      // Date filter (if selected, recurrence-aware)
      if (_selectedDate != null) {
        // For recurring tasks, check if they occur on the selected date
        if (_isRecurring(t)) {
          return _occursOn(t, _selectedDate!);
        }
        // For non-recurring tasks, check if they match the selected date
        else {
          return _isSameDay(t.date, _selectedDate!);
        }
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
    if (_isRecurring(t)) return false; // recurring ko overdue list me nahi dikhate

    final now = DateTime.now();
    final today = _todayOnly;
    final taskDay = _only(t.date);

    // Past day → overdue
    if (taskDay.isBefore(today)) return true;

    // Future day → not overdue
    if (taskDay.isAfter(today)) return false;

    // Same day → check time
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

  /// Recurring ke liye: aaj ke baad next N din me koi occurrence?
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

  /// 1) Specific date ke tasks (recurrence aware)
  List<TaskModel> get dayTasks {
    if (_selectedDate == null) return [];
    return _baseFiltered(); // date + category already applied
  }

  /// 2) Today tasks (global / show-all view) - includes completed tasks, sorted by time
  List<TaskModel> get todayTasks {
    final today = _todayOnly;
    
    // Get all tasks (including completed) that occur today
    final allTodayTasks = _tasks.where((t) {
      // Category filter
      if (_selectedCategory != 'All' && t.category != _selectedCategory) {
        return false;
      }
      
      // Check if task occurs today
      return _occursOn(t, today);
    }).toList();
    
    // Sort by time (completed tasks at the end, then by time)
    allTodayTasks.sort((a, b) {
      // First, separate completed and incomplete
      final aIsCompleted = _isRecurring(a) 
          ? a.completedDates.any((d) => _isSameDay(d, today))
          : a.completedAt != null;
      final bIsCompleted = _isRecurring(b)
          ? b.completedDates.any((d) => _isSameDay(d, today))
          : b.completedAt != null;
      
      // Incomplete tasks come first
      if (aIsCompleted != bIsCompleted) {
        return aIsCompleted ? 1 : -1;
      }
      
      // Then sort by time
      final aTime = _parseTaskDateTime(a.date, a.time);
      final bTime = _parseTaskDateTime(b.date, b.time);
      return aTime.compareTo(bTime);
    });
    
    return allTodayTasks;
  }

  /// 3) Overdue (sirf non-recurring) - sorted by time
  List<TaskModel> get overdueTasks {
    final base = _baseFiltered();
    final overdue = base.where(_isTaskOverdue).toList();
    // Sort by time (earliest first)
    overdue.sort((a, b) {
      final aTime = _parseTaskDateTime(a.date, a.time);
      final bTime = _parseTaskDateTime(b.date, b.time);
      return aTime.compareTo(bTime);
    });
    return overdue;
  }

  /// 4) Upcoming (grouped by date, recurring + non-recurring)
  Map<DateTime, List<TaskModel>> get upcomingTasks {
    final base = _baseFiltered();
    final map = <DateTime, List<TaskModel>>{};
    final today = _todayOnly;

    for (final t in base) {
      if (_isRecurring(t)) {
        // Next 30 days ke occurrences (aaj skip)
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

    // Sort tasks within each date by time
    for (final key in map.keys) {
      map[key]!.sort((a, b) {
        final aTime = _parseTaskDateTime(a.date, a.time);
        final bTime = _parseTaskDateTime(b.date, b.time);
        return aTime.compareTo(bTime);
      });
    }

    final sortedKeys = map.keys.toList()..sort();
    final ordered = <DateTime, List<TaskModel>>{};
    for (final k in sortedKeys) {
      ordered[k] = map[k]!;
    }
    return ordered;
  }

  /// 5) Flat list for Overdue/Today/Upcoming (Show All subset)
  List<TaskModel> get currentFlatTasks {
    switch (_subset) {
      case HomeFilterSubset.all:
        return _baseFiltered();
      case HomeFilterSubset.today:
        // Today: include completed tasks, sorted by time
        final today = _todayOnly;
        final allTodayTasks = _tasks.where((t) {
          // Category filter
          if (_selectedCategory != 'All' && t.category != _selectedCategory) {
            return false;
          }
          // Check if task occurs today
          return _occursOn(t, today);
        }).toList();
        
        // Sort by time (completed tasks at the end, then by time)
        allTodayTasks.sort((a, b) {
          final aIsCompleted = _isRecurring(a) 
              ? a.completedDates.any((d) => _isSameDay(d, today))
              : a.completedAt != null;
          final bIsCompleted = _isRecurring(b)
              ? b.completedDates.any((d) => _isSameDay(d, today))
              : b.completedAt != null;
          
          if (aIsCompleted != bIsCompleted) {
            return aIsCompleted ? 1 : -1;
          }
          
          final aTime = _parseTaskDateTime(a.date, a.time);
          final bTime = _parseTaskDateTime(b.date, b.time);
          return aTime.compareTo(bTime);
        });
        
        return allTodayTasks;
      case HomeFilterSubset.overdue:
        // Overdue: exclude completed tasks, sorted by time
        final base = _baseFiltered();
        final overdue = base.where(_isTaskOverdue).toList();
        overdue.sort((a, b) {
          final aTime = _parseTaskDateTime(a.date, a.time);
          final bTime = _parseTaskDateTime(b.date, b.time);
          return aTime.compareTo(bTime);
        });
        return overdue;
      case HomeFilterSubset.upcoming:
        // Upcoming: exclude completed tasks, sorted by time
        final base = _baseFiltered();
        final upcoming = base.where(_isUpcoming).toList();
        upcoming.sort((a, b) {
          // First by date
          final dateCompare = _only(a.date).compareTo(_only(b.date));
          if (dateCompare != 0) return dateCompare;
          // Then by time
          final aTime = _parseTaskDateTime(a.date, a.time);
          final bTime = _parseTaskDateTime(b.date, b.time);
          return aTime.compareTo(bTime);
        });
        return upcoming;
    }
  }

  // -------------------------------------------------
  //  RECURRENCE LABEL FOR UI
  // -------------------------------------------------

  String? recurrenceLabel(TaskModel task) {
    final rule = task.recurrenceRule?.trim();
    if (rule == null || rule.isEmpty) return null;

    if (rule == 'DAILY') {
      return 'Repeats daily';
    }

    if (rule.startsWith('WEEKLY:')) {
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final part = rule.substring('WEEKLY:'.length);
      final days = part
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList()
        ..sort();
      final labels = days
          .where((d) => d >= 1 && d <= 7)
          .map((d) => names[d - 1])
          .toList();
      if (labels.isEmpty) return 'Repeats weekly';
      return 'Every ${labels.join(', ')}';
    }

    if (rule.startsWith('MONTHLY:')) {
      final part = rule.substring('MONTHLY:'.length);
      final dom = int.tryParse(part.trim());
      if (dom == null) return 'Repeats monthly';
      return 'Monthly on the $dom';
    }

    if (rule.startsWith('YEARLY:')) {
      final part = rule.substring('YEARLY:'.length);
      final segs = part.split('-');
      if (segs.length != 2) return 'Repeats yearly';
      final month = int.tryParse(segs[0]);
      final dayNum = int.tryParse(segs[1]);
      if (month == null || dayNum == null) return 'Repeats yearly';

      const monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      final monthName =
      (month >= 1 && month <= 12) ? monthNames[month - 1] : 'Month';
      return 'Every year on $monthName $dayNum';
    }

    return 'Repeats';
  }


  // -------------------------------------------------
  //  TOGGLE COMPLETE
  // -------------------------------------------------

  Future<void> toggleComplete(TaskModel task, {DateTime? occurrenceDate}) async {
    final isRecurring = _isRecurring(task);
    
    if (isRecurring && occurrenceDate != null) {
      // For recurring tasks, track completed dates
      final dateOnly = _only(occurrenceDate);
      final currentCompletedDates = List<DateTime>.from(task.completedDates);
      
      // Check if this date is already completed
      final isDateCompleted = currentCompletedDates.any((d) => _isSameDay(d, dateOnly));
      
      if (isDateCompleted) {
        // Remove this date from completed dates
        currentCompletedDates.removeWhere((d) => _isSameDay(d, dateOnly));
      } else {
        // Add this date to completed dates
        currentCompletedDates.add(dateOnly);
      }
      
      await repo.updateTask(task.userId, task.id, {
        'completedDates': currentCompletedDates.map((d) => Timestamp.fromDate(d)).toList(),
      });
    } else {
      // For non-recurring tasks, use the old behavior
    await repo.updateTask(task.userId, task.id, {
      'completedAt': task.completedAt == null ? DateTime.now() : null,
    });
    }
  }

}
