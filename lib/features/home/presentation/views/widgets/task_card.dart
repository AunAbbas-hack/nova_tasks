// lib/features/home/presentation/views/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/task_model.dart';
import '../../viewmodels/home_viewmodel.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF11151F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue, // priority color optional
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: task.completedAt == null
                    ? Colors.white
                    : Colors.white54,
                decoration: task.completedAt != null
                    ? TextDecoration.lineThrough
                    : null,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Checkbox(
            value: task.completedAt != null,
            onChanged: (_) => vm.toggleComplete(task),
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
