import 'package:flutter/material.dart';
import 'package:nova_tasks/core/theme/app_colors.dart';
import 'package:nova_tasks/features/tasks/views/recurrence_bottomsheet.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/core/widgets/primary_button.dart';
import 'package:nova_tasks/core/widgets/primary_text_field.dart';
import 'package:nova_tasks/features/tasks/viewmodels/add_task_viewmodel.dart';

import '../../../data/models/task_model.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodels/recurrence_bottomsheet_viewmodel.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key, this.initialTask});

  /// null => Create, not-null => Edit
  final TaskModel? initialTask;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTaskViewModel(initialTask: initialTask),
      child: const _AddTaskPage(),
    );
  }
}

class _AddTaskPage extends StatelessWidget {
  const _AddTaskPage();

  Future<void> _pickDate(
      BuildContext context,
      AddTaskViewModel viewModel,
      ) async {
    FocusScope.of(context).unfocus();
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
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: viewModel.dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      viewModel.setDueTime(picked);
    }
  }

  void _showSubtaskBottomSheet(BuildContext context, AddTaskViewModel viewModel) {
    final loc=AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final TextEditingController _controller = TextEditingController();
          
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      loc.subtasksLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: loc.addSubtaskAction,
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primaryBright),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            filled: true,
                            fillColor: const Color(0xFF151A24),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (value) {
                            _addSubtask(value, _controller, viewModel, setState);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _addSubtask(_controller.text, _controller, viewModel, setState);
                        },
                        child:  Text(
                          loc.addButton,
                          style: TextStyle(
                            color: AppColors.primaryBright,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColors.primaryBright.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addSubtask(String value, TextEditingController controller, AddTaskViewModel viewModel, StateSetter setState) {
    if (value.trim().isNotEmpty) {
      viewModel.addSubtask(value.trim());
      controller.clear();
      setState(() {});
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddTaskViewModel>();
    final theme = Theme.of(context);
    final isEditing = viewModel.isEditing;
    final loc=AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          isEditing ? loc.editTaskTitle : loc.newTaskTitle,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- TITLE + DESCRIPTION ----------------
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       AppText(
                        loc.taskTitleLabel,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      PrimaryTextField(
                        label: '',
                        hint: loc.taskTitleHint,
                        controller: viewModel.titleController,
                      ),
                      const SizedBox(height: 16),
                       AppText(
                        loc.taskDescriptionLabel,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        focusNode: FocusNode(
                        ),
                        controller: viewModel.descriptionController,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: loc.taskDescriptionHint,
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                          ),

                          filled: true,
                          fillColor: const Color(0xFF151A24),



                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.2,
                            ),
                          ),
                        ),
                      )],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------------- DATE + TIME ----------------
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       AppText(loc.dueDateLabel, fontWeight: FontWeight.w600),
                      const SizedBox(height: 8),
                      _PickerTile(
                        icon: Icons.calendar_today_outlined,
                        label: _formatDate(viewModel.dueDate),
                        onTap: () => _pickDate(context, viewModel),
                      ),
                      const SizedBox(height: 16),
                         AppText(loc.timeLabel, fontWeight: FontWeight.w600),
                      const SizedBox(height: 8),
                      _PickerTile(
                        icon: Icons.access_time_rounded,
                        label: _formatTime(viewModel.dueTime),
                        onTap: () => _pickTime(context, viewModel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------------- PRIORITY + CATEGORY ----------------
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       AppText(loc.priorityLabel, fontWeight: FontWeight.w600),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          _PriorityChip(
                            label: loc.priorityLow,
                            color: Colors.blueGrey,
                            selected: viewModel.priority == TaskPriority.low,
                            onTap: () => viewModel.setPriority(TaskPriority.low),
                          ),
                          _PriorityChip(
                            label: loc.priorityMedium,
                            color: Colors.blue,
                            selected:
                            viewModel.priority == TaskPriority.medium,
                            onTap: () =>
                                viewModel.setPriority(TaskPriority.medium),
                          ),
                          _PriorityChip(
                            label: loc.priorityHigh,
                            color: Colors.orange,
                            selected: viewModel.priority == TaskPriority.high,
                            onTap: () => viewModel.setPriority(TaskPriority.high),
                          ),
                          _PriorityChip(
                            label: loc.priorityUrgent,
                            color: Colors.red,
                            selected:
                            viewModel.priority == TaskPriority.urgent,
                            onTap: () =>
                                viewModel.setPriority(TaskPriority.urgent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                       AppText(loc.categoryLabel, fontWeight: FontWeight.w600),
                      const SizedBox(height: 8),

                      // Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151A24),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: const Color(0xFF151A24),
                            value: viewModel.category,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white70,
                            ),
                            items:  [
                              DropdownMenuItem(
                                value: 'Work',
                                child: Text(loc.categoryWork),
                              ),
                              DropdownMenuItem(
                                value: 'Personal',
                                child: Text(loc.categoryPersonal),
                              ),
                              DropdownMenuItem(
                                value: 'Custom',
                                child: Text(loc.categoryCustom),
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

                      if (viewModel.isCustomSelected) ...[
                        const SizedBox(height: 12),
                        PrimaryTextField(
                          label: '',
                          hint: loc.enterCustomCategory,
                          controller: viewModel.customCategoryController,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------------- RECURRING SWITCH ----------------
                _SectionCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          AppText(
                            loc.recurringTaskLabel,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 4),
                          AppText(
                            loc.recurringTaskHint,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                      Switch(
                        value: viewModel.isRecurring,
                        onChanged: (value) async {
                          if (value == true) {
                            // OPEN BOTTOM SHEET
                            final RecurrenceSettings? result =
                            await
                                showRecurrenceBottomSheet(context);

                            if (result != null) {
                              // User pressed SAVE
                              viewModel.setRecurrence(result);
                            } else {
                              // User cancelled — keep toggle OFF
                              viewModel.clearRecurrence();
                            }
                          } else {
                            // User turned OFF the toggle
                            viewModel.clearRecurrence();
                          }
                        },
                      )

                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---------------- SUBTASKS ----------------
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       AppText(loc.subtasksLabel, fontWeight: FontWeight.w600),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           AppText(loc.subtasksProgressLabel, fontWeight: FontWeight.w600),
                          AppText(
                            '${(viewModel.progress * 100).round()}% ${loc.tasksCompletedLabel}',
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
                      // Replace the commented button section with this code
                      ListTile(
                        leading: const Icon(Icons.playlist_add, color: Colors.white70),
                        title: Text(
                        loc.addSubtaskAction,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${viewModel.subtasks.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 4),
                        onTap: () => _showSubtaskBottomSheet(context, viewModel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ---------------- CREATE / UPDATE BUTTON ----------------
                PrimaryButton(
                  label: viewModel.isSaving
                      ? (isEditing ? loc.updating : loc.creating)
                      : (isEditing ? loc.updateTaskAction : loc.createTaskAction),
                  onPressed: viewModel.isSaving
                      ? null
                      : () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text(
                           loc.loginRequiredToAddTask,
                          ),
                        ),
                      );
                      return;
                    }

                    await viewModel.saveTask(
                      userId: user.uid,
                      onSuccess: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? loc.taskUpdated
                                  : loc.taskCreated,
                            ),
                          ),
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
