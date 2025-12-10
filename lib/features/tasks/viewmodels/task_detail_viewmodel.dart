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
}