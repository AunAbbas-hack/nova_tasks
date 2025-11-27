
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/core/widgets/primary_button.dart';
import 'package:nova_tasks/core/widgets/primary_text_field.dart';
import 'package:nova_tasks/features/tasks/viewmodels/add_task_viewmodel.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTaskViewModel(),
      child: const _AddTaskContent(),
    );
  }
}

class _AddTaskContent extends StatelessWidget {
  const _AddTaskContent();

  Future<void> _pickDate(
      BuildContext context,
      AddTaskViewModel viewModel,
      ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      viewModel.setDueDate(picked);
    }
  }

  Future<void> _pickTime(
      BuildContext context,
      AddTaskViewModel viewModel,
      ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: viewModel.dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      viewModel.setDueTime(picked);
    }
  }

  void _addSubtaskDialog(BuildContext context, AddTaskViewModel viewModel) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Subtask title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.addSubtask(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddTaskViewModel>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    String formatDate(DateTime? date) {
      if (date == null) return 'Select date';
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    String formatTime(TimeOfDay? time) {
      if (time == null) return 'Select time';
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $suffix';
    }

    return Padding(
      padding: EdgeInsets.only(left: 1, right: 1, bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      AppText(
                        'New Task',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      // AppText(
                      //   'Save',
                      //   color: Colors.lightBlueAccent,
                      //   fontWeight: FontWeight.w600,
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Task Title', fontWeight: FontWeight.w600),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          label: '',
                          hint: 'e.g., Design the new dashboard',
                          controller: viewModel.titleController,
                        ),
                        const SizedBox(height: 16),
                        const AppText('Description', fontWeight: FontWeight.w600),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          label: '',
                          hint: 'Add details about the task...',
                          controller: viewModel.descriptionController,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Due Date', fontWeight: FontWeight.w600),
                        const SizedBox(height: 8),
                        _PickerTile(
                          icon: Icons.calendar_today_outlined,
                          label: formatDate(viewModel.dueDate),
                          onTap: () => _pickDate(context, viewModel),
                        ),
                        const SizedBox(height: 16),
                        const AppText('Time', fontWeight: FontWeight.w600),
                        const SizedBox(height: 8),
                        _PickerTile(
                          icon: Icons.access_time_rounded,
                          label: formatTime(viewModel.dueTime),
                          onTap: () => _pickTime(context, viewModel),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Priority', fontWeight: FontWeight.w600),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _PriorityChip(
                              label: 'Low',
                              color: Colors.blueGrey,
                              selected: viewModel.priority == TaskPriority.low,
                              onTap: () => viewModel.setPriority(TaskPriority.low),
                            ),
                            _PriorityChip(
                              label: 'Medium',
                              color: Colors.blue,
                              selected: viewModel.priority == TaskPriority.medium,
                              onTap: () =>
                                  viewModel.setPriority(TaskPriority.medium),
                            ),
                            _PriorityChip(
                              label: 'High',
                              color: Colors.orange,
                              selected: viewModel.priority == TaskPriority.high,
                              onTap: () => viewModel.setPriority(TaskPriority.high),
                            ),
                            _PriorityChip(
                              label: 'Urgent',
                              color: Colors.red,
                              selected: viewModel.priority == TaskPriority.urgent,
                              onTap: () =>
                                  viewModel.setPriority(TaskPriority.urgent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText('Category', fontWeight: FontWeight.w600),
                              const SizedBox(height: 8),

                              // Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF151A24),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    dropdownColor: const Color(0xFF151A24),
                                    value: viewModel.category,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),

                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Work',
                                        child: Text('Work'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Personal',
                                        child: Text('Personal'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Custom',
                                        child: Text('Custom'),
                                      ),
                                    ],

                                    onChanged: (value) {
                                      if (value != null) {
                                        viewModel.setCategory(value);
                                      }
                                    },
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),

                              // If custom selected → show textfield
                              if (viewModel.isCustomSelected) ...[
                                const SizedBox(height: 12),
                                PrimaryTextField(
                                  label: '',
                                  hint: 'Enter custom category',
                                  controller: TextEditingController(text: viewModel.customCategory),
                                  // onChanged: viewModel.setCustomCategory,
                                ),
                              ],
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            AppText(
                              'Recurring Task',
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 4),
                            AppText('Set task to repeat', color: Colors.white70),
                          ],
                        ),
                        Switch(
                          value: viewModel.isRecurring,
                          onChanged: viewModel.toggleRecurring,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Subtasks', fontWeight: FontWeight.w600),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText('Progress'),
                            AppText(
                              '${(viewModel.progress * 100).round()}% Completed',
                              color: Colors.white70,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: viewModel.progress,
                          minHeight: 5,
                        ),
                        const SizedBox(height: 16),
                        ...viewModel.subtasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final subtask = entry.value;
                          return CheckboxListTile(
                            value: subtask.isDone,
                            onChanged: (_) => viewModel.toggleSubtask(index),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: AppText(
                              subtask.title,
                              color: subtask.isDone
                                  ? Colors.white54
                                  : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _addSubtaskDialog(context, viewModel),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Subtask'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: viewModel.isSaving ? 'Creating...' : 'Create Task',
                    onPressed: viewModel.isSaving
                        ? null
                        : () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text('You must be logged in to add tasks')),
                        );
                        return;
                      }

                      await viewModel.saveTask(
                        userId: user.uid,
                        onSuccess: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task created')),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF11151F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF151A24),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(child: AppText(label, color: Colors.white)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color,
      backgroundColor: const Color(0xFF151A24),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
