
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_tasks/core/theme/app_colors.dart';
import 'package:nova_tasks/features/me/presentation/views/me_screen.dart';
import 'package:nova_tasks/features/me/presentation/views/notification_screen.dart';
import 'package:nova_tasks/features/me/presentation/views/settings_screen.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/task_repository.dart';
import '../../../tasks/widgets/task_card.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../tasks/views/add_task_screen.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../tasks/views/task_detail_screen.dart';

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
    final vm = context.watch<HomeViewModel>();

    // Week row dates
    final dates = _generate7Days();
    // ab selectedIndex ki jagah direct check kar lenge
    final categories = ["All", ...vm.availableCategories];

    return Scaffold(
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(theme: theme),
              const SizedBox(height: 24),

              // ------------- DATE + SHOW ALL ROW -------------
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openShowAllSheet(context, vm),
                    child: AnimatedContainer(
                      height: 44,
                      duration: const Duration(milliseconds: 180),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: vm.subset == HomeFilterSubset.all
                            ? const Color(0xFF151A24)
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        "Show All",
                        color: vm.subset == HomeFilterSubset.all
                            ? Colors.white70
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final date = dates[i];
                          final isSel = vm.selectedDate != null &&
                              _isSameDay(date, vm.selectedDate!);

                          return GestureDetector(
                            onTap: () {
                              if (isSel) {
                                // same date tap -> clear date
                                vm.clearSelectedDate();
                              } else {
                                vm.setSelectedDate(date);
                              }
                            },
                            child: AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? theme.colorScheme.primary
                                    : const Color(0xFF151A24),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: AppText(
                                "${_weekday(date)} ${date.day}",
                                color: isSel
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ------------- CATEGORY ROW -------------
              if (categories.isNotEmpty) ...[
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      final sel = cat == vm.selectedCategory;

                      return ChoiceChip(
                        label: Text(cat),
                        selected: sel,
                        selectedColor: sel
                            ? _categoryColor(cat)
                            : const Color(0xFF151A24),
                        backgroundColor: const Color(0xFF151A24),
                        labelStyle: TextStyle(
                          color:
                          sel ? Colors.black : Colors.white70,
                          fontWeight: sel
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        onSelected: (_) =>
                            vm.setSelectedCategory(cat),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ------------- MAIN CONTENT -------------
              vm.selectedDate != null
                  ? _DateModeSection(vm: vm)
                  : _ShowAllSection(vm: vm),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// -------------------------------------------------
//  DATE MODE: sirf selected date ke tasks
// -------------------------------------------------

class _DateModeSection extends StatelessWidget {
  final HomeViewModel vm;
  const _DateModeSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    final tasks = vm.dayTasks;
    final d = vm.selectedDate!;
    final title = "Tasks for ${_weekday(d)}, ${d.day}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 12),

        if (tasks.isEmpty)
          const AppText(
            "No tasks for this day.",
            color: Colors.white54,
          ),

        ...tasks.map(
              (task) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(task: task),
                ),
              ),
              child: TaskCard(task: task),
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------
//  SHOW ALL SECTION (global view)
// -------------------------------------------------

class _ShowAllSection extends StatelessWidget {
  final HomeViewModel vm;
  const _ShowAllSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    // agar subset == all → grouped view (Today/Overdue/Upcoming)
    if (vm.subset == HomeFilterSubset.all) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODAY
          if (vm.todayTasks.isNotEmpty) ...[
            const AppText(
              "Today's Tasks",
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 12),
            ...vm.todayTasks.map(
                  (t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(task: t),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // OVERDUE
          if (vm.overdueTasks.isNotEmpty) ...[
            const AppText(
              "Overdue",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            ...vm.overdueTasks.map(
                  (t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(task: t),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // UPCOMING (grouped by date)
          if (vm.upcomingTasks.isNotEmpty) ...[
            const AppText(
              "Upcoming",
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 12),
            ...vm.upcomingTasks.entries.map(
                  (entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "${_weekday(entry.key)}, ${entry.key.day}",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 8),
                  ...entry.value.map(
                        (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCard(task: t),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // warna subset specific flat list
    final list = vm.currentFlatTasks;
    String title;
    Color? color;

    switch (vm.subset) {
      case HomeFilterSubset.overdue:
        title = "Overdue Tasks";
        color = Colors.redAccent;
        break;
      case HomeFilterSubset.today:
        title = "Today's Tasks";
        color = Colors.white;
        break;
      case HomeFilterSubset.upcoming:
        title = "Upcoming Tasks";
        color = Colors.white;
        break;
      case HomeFilterSubset.all:
        title = "All Tasks";
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        const SizedBox(height: 12),

        if (list.isEmpty)
          const AppText(
            "No tasks found for this filter.",
            color: Colors.white54,
          ),

        ...list.map(
              (t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(task: t),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------
//  SHOW ALL BOTTOM SHEET
// -------------------------------------------------


void _openShowAllSheet(BuildContext context, HomeViewModel vm) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF11151F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      HomeFilterSubset selected = vm.subset; // temporary selection

      Widget buildOption(String title, HomeFilterSubset value,void Function(void Function()) setStateSheet) {
        bool isSelected = selected == value;

        return GestureDetector(
          onTap: () {
            // (context as Element).markNeedsBuild();
            // selected = value;
            setStateSheet((){
              selected = value;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFF1A1E28),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [

                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return StatefulBuilder(
        builder: (context, setStateSheet) {
          return SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),

                const AppText(
                  "Show",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),

                const SizedBox(height: 8),
                const Divider(color: Colors.white10, height: 1),

                buildOption("All (Today + Overdue + Upcoming)", HomeFilterSubset.all,setStateSheet),
                buildOption("Overdue Tasks", HomeFilterSubset.overdue,setStateSheet),
                buildOption("Today Tasks", HomeFilterSubset.today,setStateSheet),
                buildOption("Upcoming Tasks", HomeFilterSubset.upcoming,setStateSheet),

                const SizedBox(height: 16),

                // BUTTONS SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // CANCEL
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // APPLY
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            // switch logic
                            switch (selected) {
                              case HomeFilterSubset.overdue:
                                vm.setSubset(HomeFilterSubset.overdue);
                                break;
                              case HomeFilterSubset.today:
                                vm.setSubset(HomeFilterSubset.today);
                                break;
                              case HomeFilterSubset.upcoming:
                                vm.setSubset(HomeFilterSubset.upcoming);
                                break;
                              case HomeFilterSubset.all:
                              default:
                                vm.setSubset(HomeFilterSubset.all);
                                break;
                            }

                            Navigator.pop(context);
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}

// -------------------------------------------------
//  HEADER
// -------------------------------------------------

class _Header extends StatelessWidget {
  final ThemeData theme;
  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : "Guest";
    final String? profilePhoto = user?.photoURL?.trim().isNotEmpty == true
        ? user?.photoURL
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeScreen()),
              ),
              child:  CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFEEC9B7),
                backgroundImage: profilePhoto != null
                    ? NetworkImage(profilePhoto)
                    : null,
                // Agar photo null hai, to Icon dikhayein
                child: profilePhoto == null
                    ? const Icon(Icons.person, size: 30, color: Colors.black45)
                    : null,
                // ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText("HI!,", fontWeight: FontWeight.w700),
                AppText(
                  name,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -------------------------------------------------
//  HELPERS
// -------------------------------------------------

String _weekday(DateTime d) {
  const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  return names[d.weekday - 1];
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<DateTime> _generate7Days() {
  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day)
      .subtract(const Duration(days: 1));
  return List.generate(7, (i) => start.add(Duration(days: i)));
}

// Category → Color
Color _categoryColor(String category) {
  final c = category.toLowerCase();
  if (c == "work") return const Color(0xFF38BDF8);
  if (c == "personal") return const Color(0xFF34D399);
  return Colors.white70;
}
