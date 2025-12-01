import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_tasks/features/me/presentation/views/settings_screen.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../auth/views/login_screen.dart';
import '../viewmodels/me_viewmodel.dart';

class MeScreen extends StatelessWidget {
  final bool? showBack;
  const MeScreen({super.key,this.showBack});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {

      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => MeViewModel(
        repo: TaskRepository(),
        userId: user.uid,
      ),
      child:  _MeView(showBack??true),
    );
  }
}

class _MeView extends StatelessWidget {
  bool showBack;


   _MeView(this.showBack);

  Future<void> _showEditNameDialog(BuildContext context) async {
    final vm = context.read<MeViewModel>();
    final controller = TextEditingController(text: vm.name);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF11151F),
        title: const Text(
          'Edit Full Name',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await vm.updateName(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF11151F),
        title: const Text(
          'Log out',
          style: TextStyle(color: Colors.white),
        ),
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
              'Log Out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirm) return;

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeViewModel>();

    final theme = Theme.of(context);
    final surfaceDark = const Color(0xFF11151F);
    final pillBg = const Color(0xFF151A24);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: showBack,
        leading: showBack
          ? IconButton(
          onPressed: () => Navigator.pop(context),
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    )
        : null,  // tab nav hai, back ki zarurat nahi
        title: const AppText(
          'Profile',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // -------- Avatar + name --------
            const SizedBox(height: 12),
            _Avatar(primary: primary),
            const SizedBox(height: 16),
            AppText(
              vm.name,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 4),
            AppText(
              vm.email,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),

            // -------- Name + Email card --------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _ProfileRow(
                    icon: Icons.person,
                    title: 'Full Name',
                    value: vm.name,
                    onTap: () => _showEditNameDialog(context),
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _ProfileRow(
                    icon: Icons.mail_outline,
                    title: 'Email',
                    value: vm.email,
                    // Email ko abhi read-only rakhte hain
                    onTap: null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -------- Productivity Insights --------
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                'Productivity Insights',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    bg: pillBg,
                    value: vm.tasksCompleted.toString(),
                    label: 'Tasks\nCompleted',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    bg: pillBg,
                    value: '${vm.onTimeRate}%',
                    label: 'On-Time\nRate',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    bg: pillBg,
                    value: vm.currentStreak.toString(),
                    label: 'Current\nStreak',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // -------- Settings / Notifications / Logout --------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _MenuRow(
                    iconBg: pillBg,
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      // TODO: settings screen
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsScreen())
                      );
                    },
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _MenuRow(
                    iconBg: pillBg,
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () {
                      // TODO: notifications screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Notifications coming soon')),
                      );
                    },
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _MenuRow(
                    iconBg: const Color(0xFF3B1E1E),
                    icon: Icons.logout,
                    iconColor: Colors.redAccent,
                    label: 'Log Out',
                    labelColor: Colors.redAccent,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // -------- Bottom Save button (for UX feel) --------

    );
  }
}

// ---------------- small widgets ----------------

class _Avatar extends StatelessWidget {
  const _Avatar({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MeViewModel>();

    ImageProvider? imageProvider;

    if (vm.profileImageFile != null) {
      // freshly picked, local file
      imageProvider = FileImage(vm.profileImageFile!);
    } else if (vm.profileImageUrl != null &&
        vm.profileImageUrl!.isNotEmpty) {
      // saved remote url from Firestore/Storage
      imageProvider = NetworkImage(vm.profileImageUrl!);
    }
    return GestureDetector(
      onTap: (){
        vm.pickProfileImage();
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFF151A24),
            backgroundImage: imageProvider,
            child: imageProvider==null?const Icon(
              Icons.person,
              size: 52,
              color: Colors.white54,
            ):null,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF1D2330),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 2),
              AppText(
                value,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        if (onTap != null)
          const Icon(Icons.chevron_right, color: Colors.white38),
      ],
    );

    if (onTap == null) return row;

    return InkWell(
      onTap: onTap,
      child: row,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.bg,
    required this.value,
    required this.label,
  });

  final Color bg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            value,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          AppText(
            label,
            color: Colors.white70,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.iconBg,
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
    required this.onTap,
  });

  final Color iconBg;
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.white70,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              label,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: labelColor ?? Colors.white,
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38),
        ],
      ),
    );
  }
}
