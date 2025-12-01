// // lib/features/home/presentation/viewmodels/home_viewmodel.dart
//
// import 'dart:async';
// import 'package:flutter/material.dart';
//
// import '../../../../data/models/task_model.dart';
// import '../../../../data/repositories/task_repository.dart';
//
// /// Kaun sa view mode active hai?
// enum HomeViewMode {
//
//   global,   // Today + Overdue + Upcoming (default)
//   day,      // Sirf selected date ke tasks
//   showAll,  // Bottom sheet se choose: Today / Overdue / Upcoming
// }
//
// /// Show All bottom sheet ka filter
// enum ShowAllFilter {
//   today,
//   overdue,
//   upcoming,
// }
//
// class HomeViewModel extends ChangeNotifier {
//   final TaskRepository repo;
//   final String userId;
//
//   StreamSubscription? _sub;
//
//   List<TaskModel> _tasks = [];
//   List<TaskModel> get tasks => _tasks;
//
//   bool isLoading = true;
//
//   // ---------------- STATE ----------------
//
//   // Date chips ke liye selected date
//   DateTime _selectedDate = _only(DateTime.now());
//   DateTime get selectedDate => _selectedDate;
//
//   // Category filter
//   String _selectedCategory = 'All';
//   String get selectedCategory => _selectedCategory;
//
//   // View mode
//   HomeViewMode _mode = HomeViewMode.day;
//   HomeViewMode get mode => _mode;
//
//   bool _isDateFilterMode = true;
//   bool get isDateFilterMode=>_isDateFilterMode;
//
//   // Show All filter
//   ShowAllFilter _showAllFilter = ShowAllFilter.today;
//   ShowAllFilter get showAllFilter => _showAllFilter;
//
//   // Categories available from tasks
//   List<String> get availableCategories {
//     final set = <String>{};
//     for (final t in _tasks) {
//       if (t.category.trim().isNotEmpty) {
//         set.add(t.category.trim());
//       }
//     }
//     final list = set.toList()..sort();
//     return list;
//   }
//
//   HomeViewModel({required this.repo, required this.userId});
//
//   // ---------------- START REAL-TIME LISTENER ----------------
//   void resetToToday() {
//     _selectedDate = _only(DateTime.now()); // aaj
//     _selectedCategory = 'All';             // All
//     _isDateFilterMode = true;              // sirf Today mode
//     notifyListeners();
//   }
//
//
//   void start() {
//     _sub = repo.streamUserTasks(userId).listen((list) {
//       _tasks = _expandRecurring(list);
//       isLoading = false;
//       resetToToday();
//       // notifyListeners();
//     });
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
//
//   // ---------------- DATE SELECTOR ----------------
//   // 👉 Date tap → hamesha DAY MODE
//
//   void setSelectedDate(DateTime d) {
//     _selectedDate = _only(d);
//     _mode = HomeViewMode.day; // sirf is date ke tasks
//     notifyListeners();
//   }
//
//   // ---------------- CATEGORY SELECTOR ----------------
//   // 👉 Category hamesha current mode ke andar kaam karegi
//   // agar mode = day hai → sirf us date ke andar category filter
//   // agar mode = global / showAll → globally category filter
//
//   void setSelectedCategory(String category) {
//     _selectedCategory = category;
//     _mode=HomeViewMode.global;
//     notifyListeners();
//   }
//
//   bool get isFilteringAll => _selectedCategory == 'All';
//
//   // ---------------- SHOW ALL MODE ----------------
//
//   void selectShowAllFilter(ShowAllFilter filter) {
//     _showAllFilter = filter;
//     _mode = HomeViewMode.showAll;
//     notifyListeners();
//   }
//
//   /// Agar kahin se global full-view pe wapas aana ho
//   void goToGlobalMode() {
//     _mode = HomeViewMode.global;
//     notifyListeners();
//   }
//
//   // ---------------- FILTERED LIST HELPERS ----------------
//
//   List<TaskModel> _byCategory(List<TaskModel> source) {
//     if (_selectedCategory == 'All') return source;
//     return source
//         .where((t) => t.category.trim() == _selectedCategory.trim())
//         .toList();
//   }
//
//   // ---------------- VIEWS ----------------
//
//   /// 1) Selected date ke tasks (DAY MODE)
//   List<TaskModel> get selectedDateTasks {
//     final dateOnly = _only(_selectedDate);
//     final source = _tasks
//         .where((t) => _isSameDay(_only(t.date), dateOnly))
//         .toList();
//     return _byCategory(source);
//   }
//
//   /// 2) TODAY
//   List<TaskModel> get todayTasks {
//     final today = _only(DateTime.now());
//     final source =
//     _tasks.where((t) => _isSameDay(_only(t.date), today)).toList();
//     return _byCategory(source);
//   }
//
//   /// 3) OVERDUE
//   List<TaskModel> get overdueTasks {
//     final today = _only(DateTime.now());
//     final source = _tasks.where((t) {
//       final d = _only(t.date);
//       return d.isBefore(today) && t.completedAt == null;
//     }).toList();
//     return _byCategory(source);
//   }
//
//   /// 4) UPCOMING
//   Map<DateTime, List<TaskModel>> get upcomingTasks {
//     final today = _only(DateTime.now());
//     final map = <DateTime, List<TaskModel>>{};
//
//     for (final t in _tasks) {
//       final d = _only(t.date);
//       if (d.isAfter(today)) {
//         map.putIfAbsent(d, () => []).add(t);
//       }
//     }
//
//     final filtered = <DateTime, List<TaskModel>>{};
//     final sortedKeys = map.keys.toList()..sort();
//
//     for (final date in sortedKeys) {
//       final list = _byCategory(map[date]!);
//       if (list.isNotEmpty) {
//         filtered[date] = list;
//       }
//     }
//
//     return filtered;
//   }
//
//   /// 5) Show All Mode ke liye list
//   List<TaskModel> get showAllTasksFlat {
//     switch (_showAllFilter) {
//       case ShowAllFilter.today:
//         return todayTasks;
//       case ShowAllFilter.overdue:
//         return overdueTasks;
//       case ShowAllFilter.upcoming:
//       // upcoming map ko flat list bana dete hain
//         final map = upcomingTasks;
//         return [
//           for (final entry in map.entries) ...entry.value,
//         ];
//     }
//   }
//
//   // ---------------- TOGGLE COMPLETE ----------------
//
//   Future<void> toggleComplete(TaskModel task) async {
//     await repo.updateTask(task.userId, task.id, {
//       "completedAt": task.completedAt == null ? DateTime.now() : null,
//     });
//   }
//
//   // ---------------- RECURRENCE LOGIC ----------------
//
//   List<TaskModel> _expandRecurring(List<TaskModel> list) {
//     final List<TaskModel> expanded = [];
//
//     for (final task in list) {
//       if (task.recurrenceRule == null) {
//         expanded.add(task);
//         continue;
//       }
//
//       // Simple DAILY recurrence example
//       if (task.recurrenceRule == "DAILY") {
//         for (int i = 0; i < 30; i++) {
//           expanded.add(
//             task.copyWith(
//               date: _only(task.date.add(Duration(days: i))),
//             ),
//           );
//         }
//       } else {
//         expanded.add(task);
//       }
//     }
//
//     return expanded;
//   }
//
//   // ---------------- HELPERS ----------------
//
//   static bool _isSameDay(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;
//
//   static DateTime _only(DateTime d) =>
//       DateTime(d.year, d.month, d.day);
// }


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

