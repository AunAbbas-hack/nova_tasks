// lib/features/home/presentation/views/home_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_tasks/features/tasks/views/task_detail_screen.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../auth/viewmodels/signup_viewmodel.dart';
import '../../../tasks/widgets/task_card.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../tasks/views/add_task_screen.dart';
import '../../../tasks/viewmodels/add_task_viewmodel.dart';
import '../../../../core/widgets/app_text.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          HomeViewModel(repo: TaskRepository(), userId: userId)..start(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeVm = context.watch<HomeViewModel>();

    // Week dates (Mon-Fri centered around today)
    final dates = _generate5Days();
    final selectedIndex = dates.indexWhere(
      (d) => _isSameDay(d, homeVm.selectedDate),
    );

    // Categories for filter row
    final categories = ['All', ...homeVm.availableCategories];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(theme: theme),
              const SizedBox(height: 24),

              // ---------------- DATE CHIPS ----------------
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedIndex;
                    final date = dates[index];
                    final label = "${_weekday(date)} ${date.day}";

                    return GestureDetector(
                      onTap: () => homeVm.setSelectedDate(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          label,
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- CATEGORY FILTER ROW ----------------
              if (categories.isNotEmpty) ...[
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final selected = cat == homeVm.selectedCategory;
                      final color = cat == 'All'
                          ? Colors.white70
                          : _categoryColor(cat);

                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) => homeVm.setSelectedCategory(cat),
                        selectedColor: color,
                        backgroundColor: const Color(0xFF151A24),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ---------------- TODAY'S TASKS ----------------
              if (homeVm.todayTasks.isNotEmpty)
                AppText(
                  "Today's Tasks${homeVm.selectedCategory != 'All' ? ' · ${homeVm.selectedCategory}' : ''}",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              if (homeVm.todayTasks.isNotEmpty) const SizedBox(height: 12),

              ...homeVm.todayTasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task),
                        ),
                      );
                    },
                    child: TaskCard(task: task),
                  ),
                ),
              ),

              if (homeVm.todayTasks.isNotEmpty) const SizedBox(height: 24),

              // ---------------- OVERDUE ----------------
              if (homeVm.overdueTasks.isNotEmpty) ...[
                const AppText(
                  "Overdue",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                ...homeVm.overdueTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(task: task),
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          print("tap ");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetailScreen(task: task),
                            ),
                          );
                        },
                        child: TaskCard(task: task),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ---------------- UPCOMING ----------------
              // 🔹 Upcoming Header
              if (homeVm.upcomingTasks.isNotEmpty)
                const AppText(
                  "Upcoming",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),

              if (homeVm.upcomingTasks.isNotEmpty) const SizedBox(height: 12),

              // 🔹 Upcoming Task Groups
              ...homeVm.upcomingTasks.entries.map(
                (entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Heading
                    AppText(
                      "${_weekday(entry.key)}, ${entry.key.day}",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 8),

                    // Tasks List
                    ...entry.value.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            print("tap2");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskDetailScreen(task: task),
                              ),
                            );
                          },
                          child: TaskCard(task: task),
                        ), // 🔥 Now using TaskCard!
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // ---------------- FAB (UNCHANGED) ----------------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTaskScreen()));
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTaskScreen()));
        },
        backgroundColor: theme.colorScheme.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ---------------- HEADER ----------------

class _Header extends StatelessWidget {
  final ThemeData theme;

  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = (user?.displayName != null &&
        user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : 'Guest';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 26, backgroundColor: Color(0xFFEEC9B7)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('HI!,', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                AppText(userName, fontSize: 20, fontWeight: FontWeight.w700),
              ],
            ),
          ],
        ),
        const Icon(Icons.settings, color: Colors.white),
      ],
    );
  }
}

// ---------------- TASK CARD ----------------

// ---------------- Helpers ----------------

String _weekday(DateTime d) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[d.weekday - 1];
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<DateTime> _generate5Days() {
  final today = DateTime.now();
  final only = DateTime(today.year, today.month, today.day);
  // today in center: -2, -1, 0, +1, +2
  return List.generate(5, (i) => only.add(Duration(days: i - 2)));
}

// 🔥 Priority string → Color
Color _priorityColor(String priority) {
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

// 🔥 Category string → Color
Color _categoryColor(String category) {
  final c = category.toLowerCase().trim();
  if (c == 'work') return const Color(0xFF38BDF8); // sky
  if (c == 'personal') return const Color(0xFFA3E635); // lime

  // Any custom category
  return const Color(0xFF6366F1); // indigo for custom
}
