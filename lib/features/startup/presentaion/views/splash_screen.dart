import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nova_tasks/navigation_wrapper.dart';
import 'package:nova_tasks/features/auth/views/login_screen.dart';
import '../../../../core/theme/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideStartDestination();
  }

  Future<void> _decideStartDestination() async {
    // Thoda sa fake delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      // Pehli dafa app use kar raha hai → Onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    }
    else {
      // Already logged in → Direct app (NavigationWrapper)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const NavigationWrapper(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBright, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.add_task_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'TaskFlow',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(), // 👈 loading while prefs check
            ],
          ),
        ),
      ),
    );
  }
}

// Neeche wala badge agar use nahi kar rahe to hata bhi sakte ho
class _TaskFlowBadge extends StatelessWidget {
  const _TaskFlowBadge();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 86,
            width: 86,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: primary, width: 4),
            ),
          ),
          Positioned(
            top: 15,
            child: Container(
              height: 24,
              width: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary, width: 4),
              ),
            ),
          ),
          Icon(Icons.check, size: 42, color: primary),
        ],
      ),
    );
  }
}
