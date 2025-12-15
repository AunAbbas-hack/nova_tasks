import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nova_tasks/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/data/repositories/task_repository.dart';
import 'package:nova_tasks/features/tasks/viewmodels/task_detail_viewmodel.dart';
import 'package:nova_tasks/features/tasks/views/add_task_screen.dart';
import 'package:nova_tasks/features/tasks/views/recurrence_bottomsheet.dart';
import 'package:nova_tasks/features/tasks/viewmodels/recurrence_bottomsheet_viewmodel.dart';

enum RecurringDeleteOption {
  deleteAll,
  deleteUpcoming,
  deleteToday,
}

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    // HomeViewModel se repo reuse kar raha hoon

    return ChangeNotifierProvider(
      create: (_) => TaskDetailViewModel(
        repo: TaskRepository(),
        initialTask: task,
      ),
      child: const _TaskDetailView(),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView();

  String _formatDue(TaskModel task) {
    final dateStr = DateFormat('MMM d, yyyy').format(task.date);
    if (task.time.isEmpty) return dateStr;
    return '$dateStr - ${task.time}';
  }

  String _formatCompletedAt(DateTime completedAt) {
    final dateStr = DateFormat('MMM d, yyyy').format(completedAt);
    final timeStr = DateFormat('HH:mm').format(completedAt);
    return '$dateStr - $timeStr';
  }

  String _formatRecurrenceSummary(TaskDetailViewModel vm) {
    final settings = vm.getRecurrenceSettings();
    if (settings == null) return 'No recurrence';

    final buffer = StringBuffer('Repeats ');

    switch (settings.frequency) {
      case RecurrenceFrequency.daily:
        buffer.write('Daily');
        break;
      case RecurrenceFrequency.weekly:
        if (settings.weekDays.isEmpty) {
          buffer.write('Weekly');
        } else {
          const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final days = settings.weekDays.toList()..sort();
          final dayList = days.map((w) => dayNames[w - 1]).join(', ');
          buffer.write('Every $dayList');
        }
        break;
      case RecurrenceFrequency.monthly:
        buffer.write('Monthly');
        break;
      case RecurrenceFrequency.yearly:
        buffer.write('Yearly');
        break;
    }

    return buffer.toString();
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.blueGrey ;
      case 'medium':
        return const Color(0xFF60A5FA);
      case 'high':
        return Colors.orange;
      case 'urgent':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF60A5FA);
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF22C55E);
      case 'personal':
        return const Color(0xFF38BDF8);
      default:
        return const Color(0xFFA855F7); // custom
    }
  }

  /// Parse task time string (12h or 24h format) and combine with date
  DateTime? _parseTaskDateTime(DateTime baseDate, String timeStr) {
    timeStr = timeStr.trim();
    if (timeStr.isEmpty) return null;

    final year = baseDate.year;
    final month = baseDate.month;
    final day = baseDate.day;

    // Check if 24h format (e.g., "14:30")
    final is24hFormat = RegExp(r'^\d{1,2}:\d{2}$').hasMatch(timeStr);
    
    if (is24hFormat) {
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return DateTime(year, month, day, hour, minute);
    }

    // Check if 12h format (e.g., "2:30 PM" or "2:30PM")
    final regex12h = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$');
    final match = regex12h.firstMatch(timeStr);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase(); // "AM" or "PM"

      // Convert to 24h format
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskDetailViewModel>();
    final task = vm.task;
    final theme = Theme.of(context);
    final isRecurring = task.recurrenceRule != null && task.recurrenceRule!.trim().isNotEmpty;
    final priorityColor = _priorityColor(task.priority);
    final categoryColor = _categoryColor(task.category);
    final loc=AppLocalizations.of(context)!;
    
    // Check if task was overdue (only for completed, non-recurring tasks)
    // Check both date and time
    bool wasOverdue = false;
    if (task.completedAt != null && !isRecurring) {
      final now = DateTime.now();
      DateTime? taskDateTime;
      
      // Parse task date + time
      if (task.time.isNotEmpty) {
        taskDateTime = _parseTaskDateTime(task.date, task.time);
      } else {
        // If no time, use end of day (23:59:59)
        taskDateTime = DateTime(task.date.year, task.date.month, task.date.day, 23, 59, 59);
      }
      
      // Compare with current time
      if (taskDateTime != null) {
        wasOverdue = taskDateTime.isBefore(now);
      }
    }
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Top card with checkbox + title ----------
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF11151F),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: task.completedAt != null,
                      onChanged: (_) => vm.toggleTaskCompleted(),
                      activeColor: priorityColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: AppText(
                              task.title,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: vm.isCompleted
                                  ? Colors.white54
                                  : Colors.white,
                              decoration: vm.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          // Show "overdue" text only for completed overdue tasks
                          if (wasOverdue)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: AppText(loc.overdueTask
                                ,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if(isRecurring)
                      IconButton(onPressed: (){}, icon: Icon(Icons.repeat,color: Colors.white,size: 20,)),
                  ],
                ),
              ),
            ),

            // ---------- "Task Details" header with icons ----------
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF11151F),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Center(
                      child: AppText(
                        loc.taskDetails,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Edit
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTaskScreen(initialTask: task,)));
                    },
                    icon: const Icon(Icons.edit, color: Colors.white70),
                  ),
                  // Delete
                  IconButton(
                    onPressed: () async {
                      // If recurring task, show options dialog
                      if (isRecurring) {
                        final option = await _showRecurringDeleteDialog(context, loc);
                        if (option == null || !context.mounted) return;
                        
                        switch (option) {
                          case RecurringDeleteOption.deleteAll:
                            await vm.deleteAllRecurrences();
                            break;
                          case RecurringDeleteOption.deleteUpcoming:
                            await vm.deleteUpcomingRecurrences();
                            break;
                          case RecurringDeleteOption.deleteToday:
                            await vm.deleteTodayRecurrence();
                            break;
                        }
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } else {
                        // Non-recurring task - show simple confirmation
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1F2B),
                            title:  Text(
                              loc.deleteTaskTitle ,
                              style: TextStyle(color: Colors.white),
                            ),
                            content:  Text(
                              loc.deleteTaskMessage,
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child:  Text(loc.cancelAction),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child:  Text(
                                  loc.deleteAction,
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) ??
                            false;

                        if (!confirm) return;

                        await vm.deleteTask();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
                ],
              ),
            ),

            // ---------- Content ----------
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Due date, Priority, Category block
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11151F),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            icon: Icons.calendar_today_rounded,
                            iconBg: const Color(0xFF1D4ED8),
                            label: loc.dueDateLabel,
                            value: _formatDue(task),
                          ),
                          // Show "Completed At" if task is overdue and completed
                          if (wasOverdue && task.completedAt != null) ...[
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.check_circle_rounded,
                              iconBg: const Color(0xFF22C55E),
                              label: 'Completed At',
                              value: _formatCompletedAt(task.completedAt!),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.flag_rounded,
                            iconBg: priorityColor,
                            label: loc.priorityLabel,
                            value: task.priority[0].toUpperCase() +
                                task.priority.substring(1),
                            valueColor: priorityColor,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.local_offer_rounded,
                            iconBg: categoryColor,
                            label: loc.categoryLabel,
                            valueWidget: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                task.category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    AppText(
                      loc.taskDescriptionLabel,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11151F),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: AppText(
                        task.description.isEmpty
                            ? loc.noDescriptionAdded
                            : task.description,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recurrence Details (only show if recurring)
                    if (isRecurring) ...[
                      AppText(
                        'Recurrence Details',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF11151F),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatRecurrenceSummary(vm),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (vm.getRecurrenceSettings()?.endDate != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Until ${DateFormat('MMM d, yyyy').format(vm.getRecurrenceSettings()!.endDate!)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () async {
                                      final currentSettings = vm.getRecurrenceSettings();
                                      final result = await showRecurrenceBottomSheet(
                                        context,
                                        initial: currentSettings,
                                      );
                                      if (result != null && context.mounted) {
                                        await vm.updateRecurrence(result);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Recurrence updated')),
                                          );
                                        }
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Edit Recurrence'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: const Color(0xFF1A1F2B),
                                          title: const Text(
                                            'Stop Recurrence',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to stop this recurrence? This will remove the recurrence pattern but keep the task.',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text(loc.cancelAction),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text(
                                                'Stop',
                                                style: TextStyle(color: Colors.redAccent),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ) ?? false;

                                      if (confirm && context.mounted) {
                                        await vm.stopRecurrence();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Recurrence stopped')),
                                          );
                                        }
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white70,
                                      side: const BorderSide(color: Colors.white24),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Stop Recurrence'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Subtasks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          loc.subtasksLabel,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        AppText(
                          loc.subtasksCompletedStatus(vm.totalSubtasks, vm.completedSubtasks),
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _SubtasksSection(vm: vm),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // ---------- Bottom "Mark as Complete" button ----------
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: Colors.transparent,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                  vm.isUpdating ? null : vm.toggleTaskCompleted,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    vm.isCompleted
                        ? loc.markAsIncomplete
                        : loc.markAsCompleted
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// Subtasks Section with new flow
class _SubtasksSection extends StatefulWidget {
  final TaskDetailViewModel vm;
  const _SubtasksSection({required this.vm});

  @override
  State<_SubtasksSection> createState() => _SubtasksSectionState();
}

class _SubtasksSectionState extends State<_SubtasksSection> {
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final task = vm.task;
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF11151F),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: vm.subtasksProgress,
                minHeight: 8,
                backgroundColor: const Color(0xFF1A1E28),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Existing subtasks
            if (task.subtasks.isNotEmpty)
              ...task.subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final sub = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: sub.isDone,
                        onChanged: (_) => vm.toggleSubtask(index),
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          sub.title,
                          color: sub.isDone ? Colors.white54 : Colors.white,
                          decoration: sub.isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                        onPressed: () => vm.deleteSubtask(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }),

            // Add subtask textfield (when adding)
            if (vm.isAddingSubtask) ...[
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: null,
                    activeColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _subtaskController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: loc.enterSubTask,
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_)  {
                        final text = _subtaskController.text.trim();
                        if (text.isNotEmpty) {
                           vm.addSubtask(text);
                          _subtaskController.clear();
                          // Keep textfield open - viewmodel already handles this
                        } else {
                          vm.cancelAddingSubtask();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: vm.cancelAddingSubtask,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Add subtasks button
              TextButton(
                onPressed: ()  {
                  final text = _subtaskController.text.trim();
                  if (text.isNotEmpty) {
                     vm.addSubtask(text);
                    _subtaskController.clear();
                    // Keep textfield open - viewmodel already handles this
                  } else {
                    vm.cancelAddingSubtask();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(loc.addSubtaskAction),
              ),
            ] else
              // Initial "Add subtask" text
              GestureDetector(
                onTap: vm.startAddingSubtask,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AppText(
                    loc.addSubtaskAction,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Small reusable row for "Due Date / Priority / Category"
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    this.value,
    this.valueColor,
    this.valueWidget,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconBg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              valueWidget ??
                  Text(
                    value ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

}

// ================== RECURRING DELETE DIALOG ==================

Future<RecurringDeleteOption?> _showRecurringDeleteDialog(
  BuildContext context,
  AppLocalizations loc,
) async {
  RecurringDeleteOption? selectedOption;
  
  return await showDialog<RecurringDeleteOption>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2B),
        title: Text(
          loc.deleteRecurringEvent,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delete all recurrences
            RadioListTile<RecurringDeleteOption>(
              contentPadding: EdgeInsets.zero,
              title:  Text(
                loc.deleteOptionAllRecurrences,
                style: TextStyle(color: Colors.white),
              ),
              value: RecurringDeleteOption.deleteAll,
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              activeColor: Colors.redAccent,
            ),
            // Delete upcoming recurrences
            RadioListTile<RecurringDeleteOption>(
              contentPadding: EdgeInsets.zero,
              title:  Text(
              loc.deleteOptionUpcomingRecurrences,
                style: TextStyle(color: Colors.white),
              ),
              value: RecurringDeleteOption.deleteUpcoming,
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              activeColor: Colors.orange,
            ),
            // Delete today's task
            RadioListTile<RecurringDeleteOption>(
              contentPadding: EdgeInsets.zero,
              title:  Text(
                loc.deleteOptionTodayTask,
                style: TextStyle(color: Colors.white),
              ),
              value: RecurringDeleteOption.deleteToday,
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.cancelAction,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: selectedOption == null
                ? null
                : () => Navigator.pop(context, selectedOption),

            child: Text(loc.deleteAction,style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    ),
  );
}