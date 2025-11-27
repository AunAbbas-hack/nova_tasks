// import 'package:flutter/material.dart';
//
// import '../../../data/models/subtask_model.dart';
// import '../../../data/models/task_model.dart';
// import '../../../data/repositories/task_repository.dart';
//
// enum TaskPriority { low, medium, high, urgent }
//
// class Subtask {
//   Subtask({required this.title, this.isDone = false});
//
//   final String title;
//   bool isDone;
// }
//
// class AddTaskViewModel extends ChangeNotifier {
//   final titleController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final customCategoryController=TextEditingController();
//   String? _customCategory;
//   String get customCategory => _customCategory ?? '';
//   bool get isCustomSelected => _category == 'Custom';
//
//
//
//   DateTime? _dueDate;
//   TimeOfDay? _dueTime;
//   TaskPriority _priority = TaskPriority.medium;
//   bool _isRecurring = false;
//   String _category = 'Work';
//   bool _isCustomSelected = false;
//
//
//
//   String get category => _category;
//
//   final List<Subtask> _subtasks = [];
//
//   bool _isSaving = false;
//
//   DateTime? get dueDate => _dueDate;
//   TimeOfDay? get dueTime => _dueTime;
//   TaskPriority get priority => _priority;
//   bool get isRecurring => _isRecurring;
//   bool get isSaving => _isSaving;
//   List<Subtask> get subtasks => List.unmodifiable(_subtasks);
//
//   double get progress {
//     if (_subtasks.isEmpty) return 0;
//     final completed =
//     _subtasks.where((subtask) => subtask.isDone).length.toDouble();
//     return completed / _subtasks.length;
//   }
//
//   void setDueDate(DateTime date) {
//     _dueDate = date;
//     notifyListeners();
//   }
//
//   void setDueTime(TimeOfDay time) {
//     _dueTime = time;
//     notifyListeners();
//   }
//
//   void setPriority(TaskPriority value) {
//     _priority = value;
//     notifyListeners();
//   }
//
//   void setCategory(String value) {
//     _category = value;
//     _isCustomSelected = value == 'Custom';
//     notifyListeners();
//   }
//   void setCustomCategory(String value) {
//     _customCategory = value;
//     notifyListeners();
//   }
//
//
//   void toggleRecurring(bool value) {
//     _isRecurring = value;
//     notifyListeners();
//   }
//
//   void addSubtask(String title) {
//     if (title.trim().isEmpty) return;
//     _subtasks.add(Subtask(title: title.trim()));
//     notifyListeners();
//   }
//
//   void toggleSubtask(int index) {
//     if (index < 0 || index >= _subtasks.length) return;
//     _subtasks[index].isDone = !_subtasks[index].isDone;
//     notifyListeners();
//   }
//
//   void removeSubtask(int index) {
//     if (index < 0 || index >= _subtasks.length) return;
//     _subtasks.removeAt(index);
//     notifyListeners();
//   }
//
//   String _formatTime24(TimeOfDay time) {
//     final h = time.hour.toString().padLeft(2, '0');
//     final m = time.minute.toString().padLeft(2, '0');
//     return '$h:$m';
//   }
//
//   String _priorityToString(TaskPriority p) {
//     switch (p) {
//       case TaskPriority.low:
//         return 'low';
//       case TaskPriority.medium:
//         return 'medium';
//       case TaskPriority.high:
//         return 'high';
//       case TaskPriority.urgent:
//         return 'urgent';
//     }
//   }
//
//   /// 🔥 Save task to Firestore using TaskRepository
//   Future<void> saveTask({
//     required String userId,
//     required VoidCallback onSuccess,
//   }) async {
//     if (titleController.text.trim().isEmpty) return;
//
//     _isSaving = true;
//     notifyListeners();
//
//     try {
//       final now = DateTime.now();
//       final taskId = DateTime.now().millisecondsSinceEpoch.toString();
//
//       // Convert time to string
//       final timeString = _dueTime != null ? _formatTime24(_dueTime!) : '';
//
//       // Build subtasks list
//       final subtasksModels = _subtasks.asMap().entries.map((entry) {
//         final index = entry.key;
//         final sub = entry.value;
//         return SubtaskModel(
//           id: '$taskId-$index',
//           taskId: taskId,
//           title: sub.title,
//           isDone: sub.isDone,
//         );
//       }).toList();
//
//       // Correct category handling
//       final finalCategory =
//       isCustomSelected ? (_customCategory?.trim() ?? 'Custom') : _category;
//       final selectedCategory = _isCustomSelected &&
//           customCategoryController.text.trim().isNotEmpty
//           ? customCategoryController.text.trim()
//           : _category;
//       // Build TaskModel
//       final task = TaskModel(
//         id: taskId,
//         userId: userId,
//         category: selectedCategory,
//         title: titleController.text.trim(),
//         description: descriptionController.text.trim(),
//         date: _dueDate ?? now,
//         time: timeString,
//         priority: _priorityToString(_priority),
//         completedAt: null,
//         recurrenceRule: _isRecurring ? 'DAILY' : null,
//         parentTaskId: null,
//         hasAttachment: false,
//         subtasks: subtasksModels,
//         createdAt: now,
//         updatedAt: now,
//       );
//
//       final repo = TaskRepository();
//       await repo.addTask(task);
//
//       onSuccess();
//       _resetForm();
//     } catch (e) {
//       debugPrint('Error saving task: $e');
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }
//
//   void _resetForm() {
//     titleController.clear();
//     descriptionController.clear();
//     _dueDate = null;
//     _dueTime = null;
//     _priority = TaskPriority.medium;
//     _category = 'Work';
//     _isRecurring = false;
//     _subtasks.clear();
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     descriptionController.dispose();
//     customCategoryController.dispose();
//     super.dispose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/data/models/subtask_model.dart';
import 'package:nova_tasks/data/repositories/task_repository.dart';

enum TaskPriority { low, medium, high, urgent }

class Subtask {
  Subtask({required this.title, this.isDone = false});

  final String title;
  bool isDone;
}

class AddTaskViewModel extends ChangeNotifier {
  AddTaskViewModel({TaskModel? initialTask}) {
    if (initialTask != null) {
      _editingTask = initialTask;

      // Prefill fields
      titleController.text = initialTask.title;
      descriptionController.text = initialTask.description;
      _dueDate = initialTask.date;
      _dueTime = _parseTime(initialTask.time);
      _priority = _stringToPriority(initialTask.priority);

      final originalCategory = initialTask.category;
      if (originalCategory == 'Work' || originalCategory == 'Personal') {
        _category = originalCategory;
        _isCustomSelected = false;
      } else {
        _category = 'Custom';
        _isCustomSelected = true;
        customCategoryController.text = originalCategory;
      }

      _isRecurring = initialTask.recurrenceRule != null;

      _subtasks.addAll(
        initialTask.subtasks.map(
              (s) => Subtask(title: s.title, isDone: s.isDone),
        ),
      );
    }
  }

  // ---------------- CONTROLLERS ----------------

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final TextEditingController customCategoryController =
  TextEditingController();

  // ---------------- INTERNAL STATE ----------------

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskPriority _priority = TaskPriority.medium;
  String _category = 'Work';
  bool _isCustomSelected = false;
  bool _isRecurring = false;

  final List<Subtask> _subtasks = [];

  bool _isSaving = false;
  TaskModel? _editingTask; // null => create mode, not-null => edit mode

  // ---------------- GETTERS ----------------

  DateTime? get dueDate => _dueDate;
  TimeOfDay? get dueTime => _dueTime;
  TaskPriority get priority => _priority;
  String get category => _category;
  bool get isCustomSelected => _isCustomSelected;
  bool get isRecurring => _isRecurring;
  bool get isSaving => _isSaving;
  bool get isEditing => _editingTask != null;
  List<Subtask> get subtasks => List.unmodifiable(_subtasks);
  String get customCategory => customCategoryController.text;

  double get progress {
    if (_subtasks.isEmpty) return 0;
    final completed =
    _subtasks.where((subtask) => subtask.isDone).length.toDouble();
    return completed / _subtasks.length;
  }

  // ---------------- MUTATORS ----------------

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
    _isCustomSelected = value == 'Custom';
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

  // ---------------- SAVE / UPDATE TASK ----------------

  Future<void> saveTask({
    required String userId,
    required VoidCallback onSuccess,
  }) async {
    if (titleController.text.trim().isEmpty) return;

    _isSaving = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final taskId =
          _editingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final timeString =
      _dueTime != null ? _formatTime24(_dueTime!) : '';

      final categoryToSave =
      _isCustomSelected && customCategoryController.text.trim().isNotEmpty
          ? customCategoryController.text.trim()
          : _category;

      final subtasksModels = _subtasks.asMap().entries.map((entry) {
        final index = entry.key;
        final sub = entry.value;
        return SubtaskModel(
          id: '${taskId}_$index',
          taskId: taskId,
          title: sub.title,
          isDone: sub.isDone,
        );
      }).toList();

      final task = TaskModel(
        id: taskId,
        userId: userId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        date: _dueDate ?? now,
        time: timeString,
        priority: _priorityToString(_priority),
        category: categoryToSave,
        completedAt: _editingTask?.completedAt,
        recurrenceRule: _isRecurring
            ? (_editingTask?.recurrenceRule ?? 'DAILY')
            : null,
        parentTaskId: _editingTask?.parentTaskId,
        hasAttachment: _editingTask?.hasAttachment ?? false,
        subtasks: subtasksModels, createdAt: _editingTask?.createdAt??DateTime.now(), updatedAt: _editingTask?.updatedAt??DateTime.now(),
      );

      final repo = TaskRepository();

      if (_editingTask == null) {
        // CREATE
        await repo.addTask(task);
      } else {
        // UPDATE
        await repo.updateTask(userId, task.id, task.toFirestore());
      }

      onSuccess();

      // Create mode me form reset, edit mode me mat reset karo
      if (_editingTask == null) {
        _resetForm();
      }
    } catch (e) {
      debugPrint('Error saving task: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ---------------- HELPERS ----------------

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    customCategoryController.clear();
    _dueDate = null;
    _dueTime = null;
    _priority = TaskPriority.medium;
    _category = 'Work';
    _isCustomSelected = false;
    _isRecurring = false;
    _subtasks.clear();
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

  TaskPriority _stringToPriority(String s) {
    switch (s.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }

  String _formatTime24(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  TimeOfDay? _parseTime(String time) {
    if (time.isEmpty) return null;
    try {
      final base = time.split(' ').first; // "14:30" ya "02:30"
      final parts = base.split(':');
      if (parts.length != 2) return null;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    customCategoryController.dispose();
    super.dispose();
  }
}
