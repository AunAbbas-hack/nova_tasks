// lib/features/notifications/viewmodels/notifications_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';


/// Kis type ki notification hai
enum NotificationKind {
  dueSoon,
  overdue,
  productivityInsight,
  activityInfo,
}

/// UI ke liye ek simple model
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.date,
    this.task,
  });

  final String id;              // usually task.id ya synthetic id
  final NotificationKind kind;
  final String title;
  final String message;
  final DateTime date;          // kis din ki notification hai
  final TaskModel? task;        // agar task based hai to yeh fill hoga
}

class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel({
    required this.repo,
    required this.userId,
  }) {
    _init();
  }

  final TaskRepository repo;
  final String userId;

  StreamSubscription<List<TaskModel>>? _sub;
  List<TaskModel> _tasks = [];

  bool isLoading = true;

  /// sari notifications (today + yesterday)
  List<AppNotification> _notifications = [];

  /// user ne jo dismiss kar di hain unka id store
  final Set<String> _dismissedIds = {};

  List<AppNotification> get todayNotifications {
    final today = _only(DateTime.now());
    return _notifications.where((n) {
      return _isSameDay(_only(n.date), today) &&
          !_dismissedIds.contains(n.id);
    }).toList();
  }

  List<AppNotification> get yesterdayNotifications {
    final today = _only(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    return _notifications.where((n) {
      return _isSameDay(_only(n.date), yesterday) &&
          !_dismissedIds.contains(n.id);
    }).toList();
  }

  bool get hasNotifications =>
      todayNotifications.isNotEmpty || yesterdayNotifications.isNotEmpty;

  // ---------- life cycle ----------

  void _init() {
    _sub = repo.streamUserTasks(userId).listen((list) {
      _tasks = list;
      isLoading = false;
      _rebuildNotifications();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ---------- public actions ----------

  Future<void> markTaskDone(AppNotification n) async {
    final task = n.task;
    if (task == null) return;

    await repo.updateTask(task.userId, task.id, {
      'completedAt': DateTime.now(),
    });

    // optionally notification ko bhi dismiss kar do
    _dismissedIds.add(n.id);
    _rebuildNotifications();
  }

  /// Abhi simple: sirf UI se dismiss kar dete hain, task ko change nahi karte.
  void snooze(AppNotification n) {
    _dismissedIds.add(n.id);
    notifyListeners();
  }

  void clearAll() {
    for (final n in _notifications) {
      _dismissedIds.add(n.id);
    }
    notifyListeners();
  }

  void dismiss(String id) {
    _dismissedIds.add(id);
    notifyListeners();
  }

  // ---------- internal: rebuild notifications from tasks ----------
  void _rebuildNotifications() {
    final now = DateTime.now();
    final today = _only(now);
    final yesterday = today.subtract(const Duration(days: 1));

    final List<AppNotification> out = [];

    // 1) Due soon + overdue (pending tasks only)
    for (final t in _tasks) {
      if (t.completedAt != null) continue;

      final taskDateOnly = _only(t.date);
      final bool hasTime = t.time.isNotEmpty;
      final DateTime? dueDateTime =
      hasTime ? parseTaskDateTime(t.date, t.time) : null; // sirf tab jab time ho

      // ---- DUE SOON: sirf aaj + time wali ----
      if (hasTime &&
          _isSameDay(taskDateOnly, today) &&
          dueDateTime != null) {
        final diff = dueDateTime.difference(now);
        if (diff.inMinutes >= 0 && diff.inMinutes <= 60) {
          out.add(
            AppNotification(
              id: 'dueSoon_${t.id}',
              kind: NotificationKind.dueSoon,
              title: 'Task Due Soon',
              message:
              '${t.title} is due at ${t.time}.',
              date: today,
              task: t,
            ),
          );
        }
      }

      // ---- OVERDUE ----
      final bool isPastDate = taskDateOnly.isBefore(today);
      final bool isTodayPastTime = hasTime &&
          _isSameDay(taskDateOnly, today) &&
          dueDateTime != null &&
          dueDateTime.isBefore(now);

      // agar date pehle ki hai -> overdue
      // ya aaj hai + time diya hua hai + time cross ho chuka hai -> overdue
      if (isPastDate || isTodayPastTime) {
        out.add(
          AppNotification(
            id: 'overdue_${t.id}',
            kind: NotificationKind.overdue,
            title: 'Overdue Task',
            message: t.description.isNotEmpty
                ? t.description
                : 'Task "${t.title}" is overdue.',
            date: today,
            task: t,
          ),
        );
      }
    }

    // 2) Productivity Insight (yesterday completed count)
    final completedYesterday = _tasks.where((t) {
      if (t.completedAt == null) return false;
      final d = _only(t.completedAt!);
      return _isSameDay(d, yesterday);
    }).length;

    if (completedYesterday > 0) {
      out.add(
        AppNotification(
          id: 'insight_$yesterday',
          kind: NotificationKind.productivityInsight,
          title: 'Productivity Insight',
          message:
          'You completed $completedYesterday task(s) yesterday. Keep it up!',
          date: yesterday,
        ),
      );
    }

    // 3) Activity info (yesterday created tasks)
    final createdYesterday = _tasks.where((t) {
      final d = _only(t.createdAt);
      return _isSameDay(d, yesterday);
    }).length;

    if (createdYesterday > 0) {
      out.add(
        AppNotification(
          id: 'activity_$yesterday',
          kind: NotificationKind.activityInfo,
          title: 'New Tasks Yesterday',
          message:
          'You added $createdYesterday new task(s) yesterday.',
          date: yesterday,
        ),
      );
    }

    _notifications = out;
    notifyListeners();
  }


  // ---------- helpers ----------

  
  DateTime? parseTaskDateTime(DateTime date, String timeString) {
    if (timeString.trim().isEmpty) return null;

    final raw = timeString.trim();

    final year = date.year;
    final month = date.month;
    final day = date.day;


    final is24hFormat = RegExp(r'^\d{1,2}:\d{2}$').hasMatch(raw);

    if (is24hFormat) {
      final parts = raw.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      return DateTime(year, month, day, hour, minute);
    }


    final regex12h = RegExp(
        r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$'); // captures hour, minute, AM/PM
    final match = regex12h.firstMatch(raw);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase(); // "AM" or "PM"

      if (period == "PM" && hour < 12) {
        hour += 12;
      }
      if (period == "AM" && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    }


    return null;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _only(DateTime d) => DateTime(d.year, d.month, d.day);
}
