import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nova_tasks/core/widgets/bottom_nav_bar.dart';
import 'package:nova_tasks/features/me/presentation/views/me_screen.dart';
import 'package:provider/provider.dart';

import 'features/auth/viewmodels/signup_viewmodel.dart';
import 'features/calendar/presentation/views/calendar_screen.dart';
import 'features/home/presentation/views/home_screen.dart';

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
    final String userID = user?.uid ?? "";
    if (user == null) {
      return const Center(child: Text("Not Logged in"));
    }

    final List<Widget> _screens = [
      HomeScreen(userId: userID),
      const CalendarScreen(),
      const MeScreen(),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop,result)async{
        if(didPop)return;

        bool exit=await _showExitDialog();
        if(exit){
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: _screens[currentIndex],
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
