import 'package:flutter/material.dart';

import '../../../data/models/subtask_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

enum TaskPriority { low, medium, high, urgent }

class Subtask {
  Subtask({required this.title, this.isDone = false});

  final String title;
  bool isDone;
}

class AddTaskViewModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String? _customCategory;
  String get customCategory => _customCategory ?? '';
  bool get isCustomSelected => _category == 'Custom';



  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskPriority _priority = TaskPriority.medium;
  String _category = 'Work';
  bool _isRecurring = false;

  final List<Subtask> _subtasks = [];

  bool _isSaving = false;

  DateTime? get dueDate => _dueDate;
  TimeOfDay? get dueTime => _dueTime;
  TaskPriority get priority => _priority;
  String get category => _category;
  bool get isRecurring => _isRecurring;
  bool get isSaving => _isSaving;
  List<Subtask> get subtasks => List.unmodifiable(_subtasks);

  double get progress {
    if (_subtasks.isEmpty) return 0;
    final completed =
    _subtasks.where((subtask) => subtask.isDone).length.toDouble();
    return completed / _subtasks.length;
  }

  void setDueDate(DateTime date) {
    _dueDate = date;
    notifyListeners();
  }

  void setDueTime(TimeOfDay time) {
    _dueTime = time;
    notifyListeners();
  }

  void setPriority(TaskPriority value) {
    _priority = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }
  void setCustomCategory(String value) {
    _customCategory = value;
    notifyListeners();
  }


  void toggleRecurring(bool value) {
    _isRecurring = value;
    notifyListeners();
  }

  void addSubtask(String title) {
    if (title.trim().isEmpty) return;
    _subtasks.add(Subtask(title: title.trim()));
    notifyListeners();
  }

  void toggleSubtask(int index) {
    if (index < 0 || index >= _subtasks.length) return;
    _subtasks[index].isDone = !_subtasks[index].isDone;
    notifyListeners();
  }

  void removeSubtask(int index) {
    if (index < 0 || index >= _subtasks.length) return;
    _subtasks.removeAt(index);
    notifyListeners();
  }

  String _formatTime24(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _priorityToString(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
      case TaskPriority.urgent:
        return 'urgent';
    }
  }

  /// 🔥 Save task to Firestore using TaskRepository
  Future<void> saveTask({
    required String userId,
    required VoidCallback onSuccess,
  }) async {
    if (titleController.text.trim().isEmpty) return;

    _isSaving = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final taskId = DateTime.now().millisecondsSinceEpoch.toString();

      // Convert time to string
      final timeString = _dueTime != null ? _formatTime24(_dueTime!) : '';

      // Build subtasks list
      final subtasksModels = _subtasks.asMap().entries.map((entry) {
        final index = entry.key;
        final sub = entry.value;
        return SubtaskModel(
          id: '$taskId-$index',
          taskId: taskId,
          title: sub.title,
          isDone: sub.isDone,
        );
      }).toList();

      // Correct category handling
      final finalCategory =
      isCustomSelected ? (_customCategory?.trim() ?? 'Custom') : _category;

      // Build TaskModel
      final task = TaskModel(
        id: taskId,
        userId: userId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: _dueDate ?? now,
        time: timeString,
        priority: _priorityToString(_priority),
        category: finalCategory,                      // 👈 FIXED
        completedAt: null,
        recurrenceRule: _isRecurring ? 'DAILY' : null,
        parentTaskId: null,
        hasAttachment: false,
        subtasks: subtasksModels,
        createdAt: now,
        updatedAt: now,
      );

      final repo = TaskRepository();
      await repo.addTask(task);

      onSuccess();
      _resetForm();
    } catch (e) {
      debugPrint('Error saving task: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    _dueDate = null;
    _dueTime = null;
    _priority = TaskPriority.medium;
    _category = 'Work';
    _isRecurring = false;
    _subtasks.clear();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
