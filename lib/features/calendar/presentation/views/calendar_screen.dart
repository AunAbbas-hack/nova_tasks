import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/data/models/task_model.dart';
import 'package:nova_tasks/data/repositories/task_repository.dart';
import 'package:nova_tasks/features/tasks/widgets/task_card.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../tasks/views/add_task_screen.dart';
import '../viewmodels/calendar_viewmodel.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: AppText('Please log in to see your calendar.', fontSize: 16),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) =>
          CalendarViewModel(repo: TaskRepository(), userId: user.uid),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalendarViewModel>();
    final loc=AppLocalizations.of(context)!;
    final tasks = vm.visibleTasks;
    final isRange = vm.isRangeActive;

    final titleText = isRange
        ? '${loc.tasksFrom} ${formatFull(vm.rangeStart!,context)} – ${formatFull(vm.rangeEnd!,context)}'
        : '${loc.tasksFor} ${formatFull(vm.selectedDay ?? vm.focusedDay,context)}';

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTaskScreen()));
        },
        // shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Header ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  [
                      AppText(
                        loc.bottomNavCalendar,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---------- Month / Week Toggle ----------
                  _CalendarFormatToggle(),

                  const SizedBox(height: 10),

                  // ---------- TableCalendar ----------
                  _NovaTableCalendar(),

                ],
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.30,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF11151F),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ], // Optional shadow
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ... Aapka baki content same rahega ...
                            AppText(
                              titleText,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            // ...
                            Expanded(
                              child: tasks.isEmpty
                                  ?  Center(
                                      child: AppText(
                                        loc.noTasks,
                                        color: Colors.white54,
                                      ),
                                    )
                                  : ListView.separated(
                                      controller:
                                          scrollController,
                                      itemCount: tasks.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final task = tasks[index];
                                        // Determine occurrence date for recurring tasks
                                        DateTime? occurrenceDate;
                                        if (task.recurrenceRule?.trim().isNotEmpty ?? false) {
                                          // For recurring tasks, use selectedDay if single day is selected
                                          // Otherwise use task.date for range selection
                                          if (vm.selectedDay != null) {
                                            occurrenceDate = vm.selectedDay;
                                          } else if (vm.isRangeActive) {
                                            // For range, use task.date as occurrence date
                                            occurrenceDate = task.date;
                                          }
                                        }
                                        return TaskCard(
                                          task: task,
                                          occurrenceDate: occurrenceDate,
                                          onToggleComplete: (task, {occurrenceDate}) {
                                            vm.toggleComplete(task, occurrenceDate: occurrenceDate);
                                          },
                                          onDelete: (task) async {
                                            await vm.repo.deleteTask(task.userId, task.id);
                                          },
                                          onDeleteRecurring: (task, option) async {
                                            switch (option) {
                                              case RecurringDeleteOption.deleteAll:
                                                await vm.deleteAllRecurrences(task);
                                                break;
                                              case RecurringDeleteOption.deleteUpcoming:
                                                await vm.deleteUpcomingRecurrences(task);
                                                break;
                                              case RecurringDeleteOption.deleteToday:
                                                await vm.deleteTodayRecurrence(task);
                                                break;
                                            }
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ],
        ),
      ),
      // ... FAB ...
    );
  }
}

// ================= TOP FORMAT TOGGLE =================

class _CalendarFormatToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalendarViewModel>();
    final isMonth = vm.calendarFormat == CalendarFormat.month;
    final loc=AppLocalizations.of(context)!;
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
              onTap: () => context.read<CalendarViewModel>().onFormatChanged(
                CalendarFormat.month,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isMonth ? const Color(0xFF0F172A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child:  AppText(loc.month, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<CalendarViewModel>().onFormatChanged(
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
                child:  AppText(
                  loc.week,
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

    // ✅ Get current locale
    final locale = Localizations.localeOf(context);

    return TableCalendar<TaskModel>(
      // ✅ ADD THIS LINE - Calendar localization
      locale: locale.toString(), // 'en_US', 'ur_PK', etc.

      firstDay: DateTime.utc(2015, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: vm.focusedDay,
      calendarFormat: vm.calendarFormat,
      rangeSelectionMode: vm.rangeSelectionMode,
      rangeStartDay: vm.rangeStart,
      rangeEndDay: vm.rangeEnd,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) => vm.isSameDayInternal(vm.selectedDay, day),

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
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white70),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white70),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white,fontSize: 12),
        weekendStyle: TextStyle(color: Colors.white54,fontSize: 12),
      ),

      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(color: Colors.white70),
        weekendTextStyle: const TextStyle(color: Colors.white70),
        disabledTextStyle: const TextStyle(color: Colors.white24),

        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        rangeHighlightColor: theme.colorScheme.primary.withOpacity(0.20),
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
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          
          // Get unique priorities from tasks for this day
          final tasks = events.cast<TaskModel>();
          final uniquePriorities = <String>{};
          for (final task in tasks) {
            if (task.priority.isNotEmpty) {
              uniquePriorities.add(task.priority.toLowerCase());
            }
          }
          
          if (uniquePriorities.isEmpty) {
            // If no priority, show default marker
            return const Positioned(
              bottom: 4,
              child: Icon(
                Icons.circle,
                size: 5,
                color: Color(0xFF60A5FA),
              ),
            );
          }
          
          // If only one priority, show single marker
          if (uniquePriorities.length == 1) {
            final priority = uniquePriorities.first;
            return Positioned(
              bottom: 4,
              child: Icon(
                Icons.circle,
                size: 5,
                color: _priorityColor(priority),
              ),
            );
          }
          
          // Multiple priorities - show multiple markers in a row
          return Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: uniquePriorities.map((priority) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Icon(
                    Icons.circle,
                    size: 5,
                    color: _priorityColor(priority),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// ================== HELPERS ==================

/// Priority color helper (same as TaskCard)
Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'low':
      return Colors.blueGrey;
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

/// Returns formatted date like "October 26" using localized month names
String formatFull(DateTime date, BuildContext context) {
  final months = [
    AppLocalizations.of(context)!.january,
    AppLocalizations.of(context)!.february,
    AppLocalizations.of(context)!.march,
    AppLocalizations.of(context)!.april,
    AppLocalizations.of(context)!.may,
    AppLocalizations.of(context)!.june,
    AppLocalizations.of(context)!.july,
    AppLocalizations.of(context)!.august,
    AppLocalizations.of(context)!.september,
    AppLocalizations.of(context)!.october,
    AppLocalizations.of(context)!.november,
    AppLocalizations.of(context)!.december,
  ];

  final monthName = months[date.month - 1];
  return "$monthName ${date.day}";
}

