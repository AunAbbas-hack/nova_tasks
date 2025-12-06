import 'package:flutter/material.dart';
import 'package:nova_tasks/l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc=AppLocalizations.of(context)!;
    return BottomNavigationBar(
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: loc.bottomNavHome),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: loc.bottomNavCalendar,
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: loc.bottomNavMe),
      ],
    );
  }
}
