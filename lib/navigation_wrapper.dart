import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nova_tasks/core/widgets/bottom_nav_bar.dart';
import 'package:nova_tasks/features/calendar/presentation/views/calendar_screen.dart';
import 'package:nova_tasks/features/home/presentation/views/home_screen.dart';
import 'package:nova_tasks/features/me/presentation/views/me_screen.dart';
import 'package:nova_tasks/features/auth/views/login_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int currentIndex = 0;

  Future<bool> _showExitDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit the app?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Yes"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔹 Safety: If user is null, send them to LoginScreen instead of just showing a text
    if (user == null) {
      // We use Future.microtask so that navigation frame-safe ho
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String userID = user.uid;

    final List<Widget> screens = [
      HomeScreen(userId: userID),
      const CalendarScreen(),
      const MeScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final exit = await _showExitDialog();
        if (exit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
