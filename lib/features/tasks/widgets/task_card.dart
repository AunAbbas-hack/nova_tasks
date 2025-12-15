import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nova_tasks/features/tasks/views/task_detail_screen.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:nova_tasks/features/tasks/views/add_task_screen.dart';

import '../../../l10n/app_localizations.dart';

enum RecurringDeleteOption {
  deleteAll,
  deleteUpcoming,
  deleteToday,
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.occurrenceDate,
    this.onToggleComplete,
    this.onDelete,
    this.onDeleteRecurring,
  });

  final TaskModel task;
  final DateTime? occurrenceDate; // For recurring tasks - the specific date this occurrence is for
  final void Function(TaskModel task, {DateTime? occurrenceDate})? onToggleComplete;
  final Future<void> Function(TaskModel task)? onDelete;
  final Future<void> Function(TaskModel task, RecurringDeleteOption option)? onDeleteRecurring;

  @override
  Widget build(BuildContext context) {
    // Try to get HomeViewModel if available, otherwise use callbacks
    HomeViewModel? homeVm;
    try {
      homeVm = context.read<HomeViewModel>();
    } catch (_) {
      // HomeViewModel not available, will use callbacks
    }
    final loc=AppLocalizations.of(context)!;

    String localizeAmPm(String timeString) {

      return timeString
          .replaceAll('AM', loc.time_am)
          .replaceAll('PM', loc.time_pm);
    }
    String formattedTime =  localizeAmPm(DateFormat(loc.time_format).format(task.createdAt));

    // Priority & category colors
    final priorityColor = _priorityColor(task.priority);
    final categoryChipColor = _categoryChipColor(task.category);
    String _formatDue(TaskModel task) {
      final dateStr = DateFormat(loc.date_format).format(task.date);

      if (task.time.isEmpty) return dateStr;

      final localizedTime = localizeAmPm(task.time);

      return '$dateStr - $localizedTime';
    }
    final isRecurring = task.recurrenceRule != null && task.recurrenceRule!.trim().isNotEmpty;
    
    // For recurring tasks, check if this specific date is completed
    bool isCompleted = false;
    if (isRecurring && occurrenceDate != null) {
      final dateOnly = DateTime(occurrenceDate!.year, occurrenceDate!.month, occurrenceDate!.day);
      isCompleted = task.completedDates.any((d) => 
        d.year == dateOnly.year && d.month == dateOnly.month && d.day == dateOnly.day
      );
    } else {
      isCompleted = task.completedAt != null;
    }
    
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailScreen(task: task)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF11151F),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority bar
            Container(
              width: 4,
              height: 88,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),

            // Title + time + category chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    task.title,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.white54
                        : Colors.white,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  const SizedBox(height: 6),
                  //Task finished on data
                  AppText(
                    _formatDue(task),
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryChipColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: categoryChipColor.withOpacity(0.5),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.label_rounded,
                              size: 14,
                              color: categoryChipColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.category,
                              style: TextStyle(
                                color: categoryChipColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Checkbox + Update + Delete
            Column(
              children: [
                // ✅ Complete toggle
                Row(
                  children: [
                    Checkbox(
                      value: isCompleted,
                      onChanged: (_) {
                        // Use callback if provided, otherwise use HomeViewModel
                        if (onToggleComplete != null) {
                          onToggleComplete!(task, occurrenceDate: occurrenceDate);
                        } else if (homeVm != null) {
                          // For recurring tasks, pass the occurrence date
                          if (isRecurring && occurrenceDate != null) {
                            homeVm!.toggleComplete(task, occurrenceDate: occurrenceDate);
                          } else {
                            homeVm!.toggleComplete(task);
                          }
                        }
                      },
                      activeColor: priorityColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Subtask icon - show only if subtasks exist
                    if (task.subtasks.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.checklist,
                        size: 22,
                        color: Colors.white54,
                      ),
                    ],
                    const SizedBox(width: 6),
                    AppText(
                      formattedTime.toString(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),

                // ✏️ Update button
                Row(
                  children: [
                    if(isRecurring)
                      IconButton(onPressed: (){}, icon: Icon(Icons.repeat,color: Colors.white,size: 20,)),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white70,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTaskScreen(initialTask: task,)));
                      },
                    ),
                    const SizedBox(width: 2),

                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        // If recurring task, show options dialog
                        if (isRecurring) {
                          final option = await _showRecurringDeleteDialog(context, loc);
                          if (option == null || !context.mounted) return;
                          
                          if (onDeleteRecurring != null) {
                            await onDeleteRecurring!(task, option);
                          } else if (homeVm != null) {
                            switch (option) {
                              case RecurringDeleteOption.deleteAll:
                                await homeVm!.deleteAllRecurrences(task);
                                break;
                              case RecurringDeleteOption.deleteUpcoming:
                                await homeVm!.deleteUpcomingRecurrences(task);
                                break;
                              case RecurringDeleteOption.deleteToday:
                                await homeVm!.deleteTodayRecurrence(task);
                                break;
                            }
                          }
                        } else {
                          // Non-recurring task - show simple confirmation
                          final confirm = await _confirmDelete(context);
                          if (!confirm) return;

                          // Use callback if provided, otherwise use HomeViewModel
                          if (onDelete != null) {
                            await onDelete!(task);
                          } else if (homeVm != null) {
                            await homeVm!.repo.deleteTask(task.userId, task.id);
                          }
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task deleted')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- helpers ----------

  static Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return  Colors.blueGrey;
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

  static Color _categoryChipColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF38BDF8); // light blue
      case 'personal':
        return const Color(0xFF34D399); // green
      default:
        return Colors.white70; // purple for custom
    }
  }

  static Future<bool> _confirmDelete(BuildContext context) async {
    final loc=AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F2B),
            title:  Text(
              loc.deleteTaskTitle,
              style: TextStyle(color: Colors.white),
            ),
            content:  Text(
              loc.deleteTaskMessage,
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:  Text(loc.filterCancelButton),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:  Text(
                  loc.deleteAction,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<RecurringDeleteOption?> _showRecurringDeleteDialog(
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
                 loc.deleteOptionAllRecurrences ,
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

}
