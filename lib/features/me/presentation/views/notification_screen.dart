// lib/features/notifications/presentation/views/notifications_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/task_repository.dart';
import '../viewmodels/notification_viewmodel.dart'; // if you want reuse styles

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: AppText(
            'Please log in to see notifications.',
            fontSize: 16,
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => NotificationsViewModel(
        repo: TaskRepository(),
        userId: user.uid,
      ),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: const AppText(
          'Notifications',
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          TextButton(
            onPressed: vm.hasNotifications ? vm.clearAll : null,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: vm.hasNotifications
                    ? AppColors.primaryBright
                    : Colors.white24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (!vm.hasNotifications
          ? const _EmptyState()
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.todayNotifications.isNotEmpty) ...[
              const AppText(
                'Today',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 12),
              ...vm.todayNotifications.map(
                    (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationCard(item: n),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (vm.yesterdayNotifications.isNotEmpty) ...[
              const AppText(
                'Yesterday',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 12),
              ...vm.yesterdayNotifications.map(
                    (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationCard(item: n),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      )),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppText(
        "You're all caught up!\nNo notifications right now.",
        textAlign: TextAlign.center,
        color: Colors.white54,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final AppNotification item;

  Color _iconColor(BuildContext context) {
    switch (item.kind) {
      case NotificationKind.dueSoon:
        return Colors.blueAccent;
      case NotificationKind.overdue:
        return Colors.redAccent;
      case NotificationKind.productivityInsight:
        return Colors.greenAccent;
      case NotificationKind.activityInfo:
        return Colors.purpleAccent;
    }
  }

  IconData _iconData() {
    switch (item.kind) {
      case NotificationKind.dueSoon:
        return Icons.notifications_active_rounded;
      case NotificationKind.overdue:
        return Icons.error_outline_rounded;
      case NotificationKind.productivityInsight:
        return Icons.trending_up_rounded;
      case NotificationKind.activityInfo:
        return Icons.group_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<NotificationsViewModel>();
    final theme = Theme.of(context);

    final iconColor = _iconColor(context);

    final bool canSnooze = item.kind == NotificationKind.dueSoon;
    final bool canMarkDone =
        item.kind == NotificationKind.dueSoon ||
            item.kind == NotificationKind.overdue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF11151F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // icon circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconData(), color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              // text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // actions row
          if (canSnooze || canMarkDone)
            Row(
              children: [
                if (canSnooze)
                  _PillButton(
                    label: 'Snooze',
                    filled: true,
                    onTap: () => vm.snooze(item),
                  ),
                if (canSnooze && canMarkDone) const SizedBox(width: 12),
                if (canMarkDone)
                  _PillButton(
                    label: 'Mark as Done',
                    filled: false,
                    onTap: () => vm.markTaskDone(item),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = filled ? AppColors.primaryBright : const Color(0xFF1F2933);
    final fg = filled ? Colors.black : Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
