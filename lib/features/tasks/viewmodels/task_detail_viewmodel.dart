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

  // ------- Toggle whole task complete / incomplete -------

  Future<void> toggleTaskCompleted() async {
    if (_isUpdating) return;
    _isUpdating = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final newCompletedAt = isCompleted ? null : now;

      _task = _task.copyWith(completedAt: newCompletedAt);
      notifyListeners();

      await repo.updateTask(
        _task.userId,
        _task.id,
        {
          'completedAt': newCompletedAt,
        },
      );
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // ------- Toggle individual subtask -------

  Future<void> toggleSubtask(int index) async {
    if (index < 0 || index >= _task.subtasks.length) return;

    final updatedSubtasks = List<SubtaskModel>.from(_task.subtasks);
    final current = updatedSubtasks[index];
    updatedSubtasks[index] =
        current.copyWith(isDone: !current.isDone);

    _task = _task.copyWith(subTasks: updatedSubtasks);
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

  // ------- Delete task -------

  Future<void> deleteTask() async {
    await repo.deleteTask(_task.userId, _task.id);
  }
}
