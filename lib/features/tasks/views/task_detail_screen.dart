import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nova_tasks/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/data/repositories/task_repository.dart';
import 'package:nova_tasks/features/tasks/viewmodels/task_detail_viewmodel.dart';
import 'package:nova_tasks/features/tasks/views/add_task_screen.dart';

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

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return const Color(0xFF60A5FA);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFFB7185);
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskDetailViewModel>();
    final task = vm.task;
    final theme = Theme.of(context);

    final priorityColor = _priorityColor(task.priority);
    final categoryColor = _categoryColor(task.category);
    final loc=AppLocalizations.of(context)!;
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
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.flag_rounded,
                            iconBg: const Color(0xFFB91C1C),
                            label: loc.priorityLabel,
                            value: task.priority[0].toUpperCase() +
                                task.priority.substring(1),
                            valueColor: priorityColor,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.local_offer_rounded,
                            iconBg: const Color(0xFF15803D),
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
                          '${vm.completedSubtasks} of ${vm.totalSubtasks} ${loc.tasksCompletedLabel}',
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11151F),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: vm.subtasksProgress,
                            minHeight: 5,
                          ),
                          const SizedBox(height: 16),
                          if (task.subtasks.isEmpty)
                            AppText(
                              loc.noSubtasksAdded,
                              color: Colors.white70,
                            )
                          else
                            ...task.subtasks.asMap().entries.map(
                                  (entry) {
                                final index = entry.key;
                                final sub = entry.value;
                                return CheckboxListTile(
                                  value: sub.isDone,
                                  onChanged: (_) =>
                                      vm.toggleSubtask(index),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                  ListTileControlAffinity.leading,
                                  title: AppText(
                                    sub.title,
                                    color: sub.isDone
                                        ? Colors.white54
                                        : Colors.white,
                                    decoration: sub.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

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