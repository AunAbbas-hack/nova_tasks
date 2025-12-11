import 'package:flutter/material.dart';
import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/data/models/subtask_model.dart';
import 'package:nova_tasks/data/repositories/task_repository.dart';
import 'package:nova_tasks/features/tasks/viewmodels/recurrence_bottomsheet_viewmodel.dart';

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

      // ---------- Prefill ----------
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

      // Recurrence
      if (initialTask.recurrenceRule != null) {
        _recurrence = _decodeRecurrence(initialTask.recurrenceRule!);
      }

      // Subtasks
      _subtasks.addAll(
        initialTask.subtasks
            .map((s) => Subtask(title: s.title, isDone: s.isDone)),
      );
    }
  }

  // ---------------- CONTROLLERS ----------------

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final customCategoryController = TextEditingController();

  // ---------------- INTERNAL STATE ----------------

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskPriority _priority = TaskPriority.medium;
  String _category = 'Work';
  bool _isCustomSelected = false;

  // recurrence
  RecurrenceSettings? _recurrence;

  final List<Subtask> _subtasks = [];

  bool _isSaving = false;
  TaskModel? _editingTask; // null => create, not-null => edit

  // Subtask adding state
  bool _isAddingSubtask = false;
  String _subtaskText = '';

  // ---------------- GETTERS ----------------

  DateTime? get dueDate => _dueDate;
  TimeOfDay? get dueTime => _dueTime;
  TaskPriority get priority => _priority;
  String get category => _category;
  bool get isCustomSelected => _isCustomSelected;
  bool get isRecurring => _recurrence != null;
  RecurrenceSettings? get recurrence => _recurrence;

  bool get isSaving => _isSaving;
  bool get isEditing => _editingTask != null;
  List<Subtask> get subtasks => List.unmodifiable(_subtasks);
  String get customCategory => customCategoryController.text;

  // Subtask adding state getters
  bool get isAddingSubtask => _isAddingSubtask;
  String get subtaskText => _subtaskText;

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

  // Subtask management
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

  void addSubtask(String title) {
    if (title.trim().isEmpty) return;
    _subtasks.add(Subtask(title: title.trim()));
    // Keep adding mode open for next subtask
    _isAddingSubtask = true;
    notifyListeners();
  }

  void addSubtaskFromText() {
    if (_subtaskText.trim().isEmpty) {
      cancelAddingSubtask();
      return;
    }
    addSubtask(_subtaskText.trim());
    _subtaskText = '';
    // Keep adding mode open for next subtask
    _isAddingSubtask = true;
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

  // ---- Recurrence ----

  void setRecurrence(RecurrenceSettings settings) {
    _recurrence = settings;
    notifyListeners();
  }

  void clearRecurrence() {
    _recurrence = null;
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
      final existing = _editingTask;

      // Unique ID for new task
      final taskId =
          existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Time string UI ke liye (24h format)
      final timeString = _dueTime != null ? _formatTime24(_dueTime!) : '';

      // Category resolve (custom / normal)
      final categoryToSave =
      _isCustomSelected && customCategoryController.text.trim().isNotEmpty
          ? customCategoryController.text.trim()
          : _category;

      // 🔥 dueAt = exact deadline (date + time)
      final baseDate = _dueDate ?? now;
      final dueAt = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        _dueTime?.hour ?? 0,
        _dueTime?.minute ?? 0,
      );

      // Subtasks build
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

        completedAt: existing?.completedAt,

        // 🔁 recurrence as string
        recurrenceRule:
        _recurrence != null ? _encodeRecurrence(_recurrence!) : null,
        parentTaskId: existing?.parentTaskId,
        hasAttachment: existing?.hasAttachment ?? false,
        subtasks: subtasksModels,

        createdAt: existing?.createdAt ?? now,
        updatedAt: now,

        // 🔥 NEW: exact deadline
        dueAt: dueAt,

        // 🔥 NEW: reminder flags – edit case mein purane hi rehne chahiye
        reminder24Sent: existing?.reminder24Sent ?? false,
        reminder60Sent: existing?.reminder60Sent ?? false,
        reminder30Sent: existing?.reminder30Sent ?? false,
        reminder10Sent: existing?.reminder10Sent ?? false,
        reminder5Sent: existing?.reminder5Sent ?? false,
        overdueSent: existing?.overdueSent ?? false,
      );

      final repo = TaskRepository();

      debugPrint('💾 Saving task: ${task.title}');
      debugPrint('💾 Task ID: ${task.id}');
      debugPrint('💾 User ID: $userId');

      if (existing == null) {
        // New task
        debugPrint('💾 Creating new task...');
        await repo.addTask(task);
        debugPrint('✅ Task created successfully');
      } else {
        // Edit task → poora document overwrite (safe because hum sab fields de rahe)
        debugPrint('💾 Updating existing task...');
        await repo.updateTask(userId, task.id, task.toFirestore());
        debugPrint('✅ Task updated successfully');
      }

      onSuccess();

      if (existing == null) {
        _resetForm();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving task: $e');
      debugPrint('Stack trace: $stackTrace');
      // Re-throw to let UI handle it
      rethrow;
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
    _recurrence = null;
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
      final base = time.split(' ').first; // "14:30"
      final parts = base.split(':');
      if (parts.length != 2) return null;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return null;
    }
  }

  // ---------- Recurrence encode/decode (simple RRULE-like string) ----------

  String _encodeRecurrence(RecurrenceSettings r) {
    // Very simple encoding; you can later upgrade to real RRULE if you want
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
          // Format date as yyyy-MM-dd with zero-padding
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
    // Basic parser matching _encodeRecurrence format
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
        final dateStr = part.substring(6); // yyyy-MM-dd
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    customCategoryController.dispose();
    super.dispose();
  }
}
