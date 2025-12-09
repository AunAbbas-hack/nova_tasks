import 'package:flutter/material.dart';

import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/data/models/subtask_model.dart';
import 'package:nova_tasks/data/repositories/task_repository.dart';

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

  bool get isCompleted => _task.completedAt != null;

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

  Future<void> deleteTask() async {
    await repo.deleteTask(_task.userId, _task.id);
  }
}