import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nova_tasks/features/tasks/views/task_detail_screen.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:nova_tasks/features/tasks/views/add_task_screen.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final homeVm = context.read<HomeViewModel>();
    String formattedTime = DateFormat('hh:mm a').format(task.createdAt);

    // Priority & category colors
    final priorityColor = _priorityColor(task.priority);
    final categoryChipColor = _categoryChipColor(task.category);
    String _formatDue(TaskModel task) {
      final dateStr = DateFormat('MMM d, yyyy').format(task.date);
      if (task.time.isEmpty) return dateStr;
      return '$dateStr - ${task.time}';
    }
    final isRecurring=task.recurrenceRule !=null &&task.recurrenceRule!.trim().isNotEmpty;
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
                    color: task.completedAt == null
                        ? Colors.white
                        : Colors.white54,
                    decoration: task.completedAt != null
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
                      value: task.completedAt != null,
                      onChanged: (_) => homeVm.toggleComplete(task),
                      activeColor: priorityColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 2),
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

                    // 🗑 Delete button
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final confirm = await _confirmDelete(context);
                        if (!confirm) return;

                        await homeVm.repo.deleteTask(task.userId, task.id);

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
        return const Color(0xFF60A5FA); // blue
      case 'medium':
        return const Color(0xFFF59E0B); // amber
      case 'high':
        return const Color(0xFFFB7185); // pink
      case 'urgent':
        return const Color(0xFFEF4444); // red
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
        return const Color(0xFFA855F7); // purple for custom
    }
  }

  static Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F2B),
            title: const Text(
              'Delete Task?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to delete this task?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }


}
