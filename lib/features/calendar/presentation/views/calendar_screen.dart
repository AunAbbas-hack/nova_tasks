import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/data/repositories/task_repository.dart';
import 'package:nova_tasks/features/tasks/views/add_task_screen.dart';
import 'package:nova_tasks/features/tasks/views/task_detail_screen.dart';

import '../viewmodels/calendar_viewmodel.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: AppText(
            'Please log in to see your calendar.',
            fontSize: 16,
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(
        repo: TaskRepository(),
        userId: user.uid,
      ),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<CalendarViewModel>();

    final tasks = vm.visibleTasks;
    final isRange = vm.isRangeActive;

    final titleText = isRange
        ? 'Tasks from ${_formatFull(vm.rangeStart!)} – ${_formatFull(vm.rangeEnd!)}'
        : 'Tasks for ${_formatFull(vm.selectedDay ?? vm.focusedDay)}';

    final subtitleText = isRange
        ? '${vm.visibleTasksCount} task(s) in this range'
        : '${vm.visibleTasksCount} task(s) for this day';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  AppText(
                    'Calendar',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  Icon(Icons.calendar_today_outlined, color: Colors.white),
                ],
              ),
              const SizedBox(height: 24),

              // ---------- Month / Week Toggle ----------
              _CalendarFormatToggle(),

              const SizedBox(height: 24),

              // ---------- TableCalendar ----------
              _NovaTableCalendar(),

              const SizedBox(height: 24),

              // ---------- Tasks Card ----------
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF11151F),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        titleText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        subtitleText,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        color: Colors.white12,
                        height: 1,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: tasks.isEmpty
                            ? const Center(
                          child: AppText(
                            'No tasks for this selection.',
                            color: Colors.white54,
                          ),
                        )
                            : ListView.separated(
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) =>
                          const Divider(
                            color: Colors.white10,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return _CalendarTaskTile(task: task);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ---------- FAB ----------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            backgroundColor: Colors.transparent,
            builder: (sheetContext) {
              return DraggableScrollableSheet(
                initialChildSize: 0.9,
                maxChildSize: 1,
                minChildSize: 0.3,
                expand: false,
                builder: (context, scrollController) {
                  return const AddTaskScreen();
                },
              );
            },
          );
        },
        backgroundColor: theme.colorScheme.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ================= TOP FORMAT TOGGLE =================

class _CalendarFormatToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalendarViewModel>();
    final isMonth = vm.calendarFormat == CalendarFormat.month;

    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF151A24),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<CalendarViewModel>().onFormatChanged(
                    CalendarFormat.month,
                  ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isMonth
                      ? const Color(0xFF0F172A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const AppText(
                  'Month',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<CalendarViewModel>().onFormatChanged(
                    CalendarFormat.week,
                  ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !isMonth
                      ? const Color(0xFF0F172A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const AppText(
                  'Week',
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= TABLE CALENDAR WIDGET =================

class _NovaTableCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalendarViewModel>();
    final theme = Theme.of(context);

    return TableCalendar<TaskModel>(
      firstDay: DateTime.utc(2015, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: vm.focusedDay,
      calendarFormat: vm.calendarFormat,
      rangeSelectionMode: vm.rangeSelectionMode,
      rangeStartDay: vm.rangeStart,
      rangeEndDay: vm.rangeEnd,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      selectedDayPredicate: (day) =>
          vm.isSameDayInternal(vm.selectedDay, day),

      eventLoader: vm.getTasksForDay,

      onDaySelected: (selectedDay, focusedDay) {
        vm.onDaySelected(selectedDay, focusedDay);
      },
      onRangeSelected: (start, end, focusedDay) {
        vm.onRangeSelected(start, end, focusedDay);
      },
      onFormatChanged: vm.onFormatChanged,
      onPageChanged: vm.onPageChanged,

      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        leftChevronIcon:
        Icon(Icons.chevron_left, color: Colors.white70),
        rightChevronIcon:
        Icon(Icons.chevron_right, color: Colors.white70),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white54),
        weekendStyle: TextStyle(color: Colors.white54),
      ),

      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(color: Colors.white70),
        weekendTextStyle: const TextStyle(color: Colors.white70),
        disabledTextStyle:
        const TextStyle(color: Colors.white24),

        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        rangeHighlightColor:
        theme.colorScheme.primary.withOpacity(0.20),
        rangeStartDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),

        markerDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        markersAlignment: Alignment.bottomCenter,
        markersMaxCount: 1,
      ),

      calendarBuilders: CalendarBuilders(
        // small dot under day if has tasks
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          return const Positioned(
            bottom: 4,
            child: Icon(
              Icons.circle,
              size: 5,
              color: Color(0xFFF97316), // small orange dot
            ),
          );
        },
      ),
    );
  }
}

// ================== TASK TILE (LIST) ==================

class _CalendarTaskTile extends StatelessWidget {
  const _CalendarTaskTile({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CalendarViewModel>();
    final isDone = task.completedAt != null;

    final timeText = task.time.isEmpty
        ? ''
        : task.time; // you can format if storing 24h etc.

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Checkbox-like circle
            GestureDetector(
              onTap: () => vm.toggleComplete(task),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDone
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone
                        ? Colors.transparent
                        : Colors.white38,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // Title + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    task.title,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                    isDone ? Colors.white54 : Colors.white,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  if (timeText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AppText(
                      timeText,
                      color: Colors.white54,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== HELPERS ==================

String _formatFull(DateTime d) {
  // e.g. "October 26"
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final monthName = months[d.month - 1];
  return '$monthName ${d.day}';
}

