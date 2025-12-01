import 'package:flutter/material.dart';
import 'package:nova_tasks/features/me/presentation/views/me_screen.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/features/auth/views/login_screen.dart';

import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = vm.currentUserName ?? 'User';
    final email = vm.currentUserEmail ?? 'no-email';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------- AppBar style header ----------
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                  ),
                  const Expanded(
                    child: Center(
                      child: AppText(
                        'Settings',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // to balance back button space
                ],
              ),
              const SizedBox(height: 16),

              // --------- Account card ----------
              GestureDetector(
                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>MeScreen(showBack: true,)));},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11151F),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      // fake avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE5D3B0),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              name,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              email,
                              color: Colors.white60,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --------- APPEARANCE ----------
              const _SectionHeader(title: 'APPEARANCE'),
              const SizedBox(height: 12),

              // Dark Mode
              _SettingsCard(
                children: [
                  _IconTile(
                    icon: Icons.dark_mode_rounded,
                    iconBgColor: const Color(0xFF111827),
                    title: 'Dark Mode',
                    subtitle: 'System Default',
                    trailing: Switch(
                      value: vm.darkMode,
                      onChanged: (val) {
                        vm.setDarkMode(val);
                        // NOTE: Tum baad me yahan actual theme change hook kar sakte ho
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _IconTile(
                    icon: Icons.home_rounded,
                    iconBgColor: const Color(0xFF111827),
                    title: 'Default Home View',
                    subtitle: vm.defaultHomeView,
                    onTap: () => _showHomeViewDialog(context, vm),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.white54),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --------- GENERAL ----------
              const _SectionHeader(title: 'GENERAL'),
              const SizedBox(height: 12),

              _SettingsCard(
                children: [
                  _IconTile(
                    icon: Icons.notifications_active_outlined,
                    iconBgColor: const Color(0xFF111827),
                    title: 'Default Reminder Time',
                    subtitle: _formatTimeOfDay(vm.defaultReminderTime),
                    onTap: () => _pickReminderTime(context, vm),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.white54),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _IconTile(
                    icon: Icons.language_rounded,
                    iconBgColor: const Color(0xFF111827),
                    title: 'Language',
                    subtitle: vm.language,
                    onTap: () => _showLanguageDialog(context, vm),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.white54),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --------- ACCOUNT ----------
              const _SectionHeader(title: 'ACCOUNT'),
              const SizedBox(height: 12),

              _SettingsCard(
                children: [
                  _IconTile(
                    icon: Icons.logout_rounded,
                    iconBgColor: const Color(0xFF3F1D1D),
                    iconColor: const Color(0xFFEF4444),
                    title: 'Logout',
                    titleColor: const Color(0xFFEF4444),
                    onTap: () => _confirmLogout(context, vm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------- dialogs / pickers -------

  static Future<void> _showHomeViewDialog(
      BuildContext context, SettingsViewModel vm) async {
    final options = ['Today', 'Week'];
    String temp = vm.defaultHomeView;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF11151F),
        title: const Text('Default Home View',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (o) => RadioListTile<String>(
              value: o,
              groupValue: temp,
              onChanged: (v) {
                if (v == null) return;
                temp = v;
                vm.setDefaultHomeView(v);
                Navigator.pop(context);
              },
              title: Text(o, style: const TextStyle(color: Colors.white)),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  static Future<void> _pickReminderTime(
      BuildContext context, SettingsViewModel vm) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: vm.defaultReminderTime,
    );
    if (picked != null) {
      vm.setDefaultReminderTime(picked);
    }
  }

  static Future<void> _showLanguageDialog(
      BuildContext context, SettingsViewModel vm) async {
    final options = ['English', 'Urdu'];
    String temp = vm.language;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF11151F),
        title:
        const Text('Language', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (o) => RadioListTile<String>(
              value: o,
              groupValue: temp,
              onChanged: (v) {
                if (v == null) return;
                temp = v;
                vm.setLanguage(v);
                Navigator.pop(context);
              },
              title: Text(o, style: const TextStyle(color: Colors.white)),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  static Future<void> _confirmLogout(
      BuildContext context, SettingsViewModel vm) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF11151F),
        title: const Text('Logout',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out?',
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
              'Logout',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (!yes) return;

    await vm.logout();

    // sab routes clear karke login pe bhej do
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  static String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }
}

// ------------- small reusable widgets -------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppText(
      title,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Colors.white54,
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF11151F),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: children,
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = Colors.white,
    this.titleColor = Colors.white,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    AppText(
                      subtitle!,
                      color: Colors.white60,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
