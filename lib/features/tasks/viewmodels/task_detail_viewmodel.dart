import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/data/models/subtask_model.dart';
import 'package:nova_tasks/data/repositories/task_repository.dart';
import 'package:nova_tasks/features/tasks/viewmodels/recurrence_bottomsheet_viewmodel.dart';

class TaskDetailViewModel extends ChangeNotifier {
  TaskDetailViewModel({
    required this.repo,
    required TaskModel initialTask,
  }) : _task = initialTask;

  final TaskRepository repo;

  TaskModel _task;
  TaskModel get task => _task;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  // Subtask adding state
  bool _isAddingSubtask = false;
  String _subtaskText = '';

  bool get isCompleted => _task.completedAt != null;

  // Subtask adding state getters
  bool get isAddingSubtask => _isAddingSubtask;
  String get subtaskText => _subtaskText;

  int get totalSubtasks => _task.subtasks.length;

  int get completedSubtasks =>
      _task.subtasks.where((s) => s.isDone).length;

  double get subtasksProgress {
    if (totalSubtasks == 0) return 0;
    return completedSubtasks / totalSubtasks;
  }

  Future<void> toggleTaskCompleted() async {
    if (_isUpdating) return;
    _isUpdating = true;
    notifyListeners();

    try {
      final newCompletedAt = isCompleted ? null : DateTime.now();

      // ✅ FIX: Manual task creation instead of copyWith
      _task = TaskModel(
        id: _task.id,
        userId: _task.userId,
        title: _task.title,
        description: _task.description,
        date: _task.date,
        time: _task.time,
        priority: _task.priority,
        category: _task.category,
        completedAt: newCompletedAt,  // ✅ Direct null assignment works
        recurrenceRule: _task.recurrenceRule,
        parentTaskId: _task.parentTaskId,
        hasAttachment: _task.hasAttachment,
        subtasks: _task.subtasks,
        createdAt: _task.createdAt,
        updatedAt: DateTime.now(),
        dueAt: _task.dueAt,
        reminder24Sent: _task.reminder24Sent,
        reminder60Sent: _task.reminder60Sent,
        reminder30Sent: _task.reminder30Sent,
        reminder10Sent: _task.reminder10Sent,
        reminder5Sent: _task.reminder5Sent,
        overdueSent: _task.overdueSent,
      );

      notifyListeners();

      await repo.updateTask(
        _task.userId,
        _task.id,
        {'completedAt': newCompletedAt},
      );
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> toggleSubtask(int index) async {
    if (index < 0 || index >= _task.subtasks.length) return;

    final updatedSubtasks = List<SubtaskModel>.from(_task.subtasks);
    final current = updatedSubtasks[index];
    updatedSubtasks[index] = current.copyWith(isDone: !current.isDone);

    _task = _task.copyWith(subtasks: updatedSubtasks);
    notifyListeners();

    await repo.updateTask(
      _task.userId,
      _task.id,
      {
        'subtasks': [
          for (final s in updatedSubtasks) {'id': s.id, ...s.toJson()},
        ],
      },
    );
  }

  // Subtask adding state management
  void startAddingSubtask() {
    _isAddingSubtask = true;
    _subtaskText = '';
    notifyListeners();
  }

  void cancelAddingSubtask() {
    _isAddingSubtask = false;
    _subtaskText = '';
    notifyListeners();
  }

  void setSubtaskText(String text) {
    _subtaskText = text;
    notifyListeners();
  }

  Future<void> addSubtask(String title) async {
    if (title.trim().isEmpty) return;

    final newSubtask = SubtaskModel(
      id: '${_task.id}_${DateTime.now().millisecondsSinceEpoch}',
      taskId: _task.id,
      title: title.trim(),
      isDone: false,
    );

    final updatedSubtasks = List<SubtaskModel>.from(_task.subtasks)..add(newSubtask);

    _task = _task.copyWith(subtasks: updatedSubtasks);
    // Keep adding mode open for next subtask
    _isAddingSubtask = true;
    notifyListeners();

    await repo.updateTask(
      _task.userId,
      _task.id,
      {
        'subtasks': [
          for (final s in updatedSubtasks) {'id': s.id, ...s.toJson()},
        ],
      },
    );
  }

  Future<void> addSubtaskFromText() async {
    if (_subtaskText.trim().isEmpty) {
      cancelAddingSubtask();
      return;
    }
    await addSubtask(_subtaskText.trim());
    _subtaskText = '';
    // Keep adding mode open for next subtask
    _isAddingSubtask = true;
    notifyListeners();
  }


  Future<void> deleteSubtask(int index) async {
    if (index < 0 || index >= _task.subtasks.length) return;

    final updatedSubtasks = List<SubtaskModel>.from(_task.subtasks)..removeAt(index);

    _task = _task.copyWith(subtasks: updatedSubtasks);
    notifyListeners();

    await repo.updateTask(
      _task.userId,
      _task.id,
      {
        'subtasks': [
          for (final s in updatedSubtasks) {'id': s.id, ...s.toJson()},
        ],
      },
    );
  }

  Future<void> deleteTask() async {
    await repo.deleteTask(_task.userId, _task.id);
  }

  /// Delete all recurrences of this task
  Future<void> deleteAllRecurrences() async {
    await repo.deleteTask(_task.userId, _task.id);
  }

  /// Delete upcoming recurrences (set UNTIL date to yesterday to keep today)
  Future<void> deleteUpcomingRecurrences() async {
    if (_task.recurrenceRule == null || _task.recurrenceRule!.isEmpty) {
      return;
    }

    // Keep today and delete from tomorrow onwards
    // So UNTIL should be set to today (since UNTIL is inclusive)
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final untilDateStr = '${todayOnly.year.toString().padLeft(4, '0')}-${todayOnly.month.toString().padLeft(2, '0')}-${todayOnly.day.toString().padLeft(2, '0')}';
    
    // Parse existing recurrence rule
    final parts = _task.recurrenceRule!.split(';').map((e) => e.split('=')).toList();
    
    // Remove existing UNTIL if present
    parts.removeWhere((part) => part.isNotEmpty && part[0] == 'UNTIL');
    
    // Add new UNTIL date (today, which is inclusive)
    parts.add(['UNTIL', untilDateStr]);
    
    final newRecurrenceRule = parts.map((part) => part.join('=')).join(';');
    
    _task = _task.copyWith(recurrenceRule: newRecurrenceRule);
    notifyListeners();
    
    await repo.updateTask(
      _task.userId,
      _task.id,
      {'recurrenceRule': newRecurrenceRule},
    );
  }

  /// Delete today's recurrence (add today to exception dates)
  Future<void> deleteTodayRecurrence() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    
    // Check if already in exception dates
    final existingExceptions = List<DateTime>.from(_task.exceptionDates);
    final isAlreadyException = existingExceptions.any((d) => 
      d.year == todayOnly.year && d.month == todayOnly.month && d.day == todayOnly.day
    );
    
    if (!isAlreadyException) {
      existingExceptions.add(todayOnly);
      
      _task = _task.copyWith(exceptionDates: existingExceptions);
      notifyListeners();
      
      await repo.updateTask(
        _task.userId,
        _task.id,
        {'exceptionDates': existingExceptions.map((d) => Timestamp.fromDate(d)).toList()},
      );
    }
  }

  // ---------- Recurrence encode/decode ----------

  RecurrenceSettings? getRecurrenceSettings() {
    if (_task.recurrenceRule == null || _task.recurrenceRule!.isEmpty) {
      return null;
    }
    return _decodeRecurrence(_task.recurrenceRule!);
  }

  String _encodeRecurrence(RecurrenceSettings r) {
    final buffer = StringBuffer();

    switch (r.frequency) {
      case RecurrenceFrequency.daily:
        buffer.write('F=DAILY');
        break;
      case RecurrenceFrequency.weekly:
        buffer.write('F=WEEKLY');
        if (r.weekDays.isNotEmpty) {
          final days = r.weekDays.toList()..sort();
          buffer.write(';BYDAY=${days.join(",")}');
        }
        break;
      case RecurrenceFrequency.monthly:
        buffer.write('F=MONTHLY');
        break;
      case RecurrenceFrequency.yearly:
        buffer.write('F=YEARLY');
        break;
    }

    switch (r.endType) {
      case RecurrenceEndType.never:
        break;
      case RecurrenceEndType.onDate:
        if (r.endDate != null) {
          final d = r.endDate!;
          final year = d.year.toString();
          final month = d.month.toString().padLeft(2, '0');
          final day = d.day.toString().padLeft(2, '0');
          buffer.write(';UNTIL=$year-$month-$day');
        }
        break;
      case RecurrenceEndType.afterCount:
        if (r.endCount != null) {
          buffer.write(';COUNT=${r.endCount}');
        }
        break;
    }

    return buffer.toString();
  }

  RecurrenceSettings _decodeRecurrence(String rule) {
    final parts = rule.split(';');
    RecurrenceFrequency freq = RecurrenceFrequency.daily;
    Set<int> weekDays = {};
    RecurrenceEndType endType = RecurrenceEndType.never;
    DateTime? endDate;
    int? endCount;

    for (final part in parts) {
      if (part.startsWith('F=')) {
        final f = part.substring(2);
        switch (f) {
          case 'DAILY':
            freq = RecurrenceFrequency.daily;
            break;
          case 'WEEKLY':
            freq = RecurrenceFrequency.weekly;
            break;
          case 'MONTHLY':
            freq = RecurrenceFrequency.monthly;
            break;
          case 'YEARLY':
            freq = RecurrenceFrequency.yearly;
            break;
        }
      } else if (part.startsWith('BYDAY=')) {
        final days = part.substring(6).split(',');
        weekDays = days
            .where((e) => e.isNotEmpty)
            .map((e) => int.tryParse(e) ?? 1)
            .toSet();
      } else if (part.startsWith('UNTIL=')) {
        final dateStr = part.substring(6);
        final dParts = dateStr.split('-');
        if (dParts.length == 3) {
          final y = int.tryParse(dParts[0]) ?? DateTime.now().year;
          final m = int.tryParse(dParts[1]) ?? 1;
          final d = int.tryParse(dParts[2]) ?? 1;
          endDate = DateTime(y, m, d);
          endType = RecurrenceEndType.onDate;
        }
      } else if (part.startsWith('COUNT=')) {
        final c = int.tryParse(part.substring(6));
        if (c != null) {
          endCount = c;
          endType = RecurrenceEndType.afterCount;
        }
      }
    }

    return RecurrenceSettings(
      frequency: freq,
      weekDays: weekDays,
      endType: endType,
      endDate: endDate,
      endCount: endCount,
    );
  }

  /// Update recurrence settings
  Future<void> updateRecurrence(RecurrenceSettings settings) async {
    final newRule = _encodeRecurrence(settings);
    _task = _task.copyWith(recurrenceRule: newRule);
    notifyListeners();

    await repo.updateTask(
      _task.userId,
      _task.id,
      {'recurrenceRule': newRule},
    );
  }

  /// Stop recurrence (remove recurrence rule)
  Future<void> stopRecurrence() async {
    _task = _task.copyWith(recurrenceRule: '');
    notifyListeners();

    await repo.updateTask(
      _task.userId,
      _task.id,
      {'recurrenceRule': ''},
    );
  }
}