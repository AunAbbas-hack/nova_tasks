import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/features/auth/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/widgets/primary_button.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import 'onboarding_widgets/onboarding_page_1.dart';
import 'onboarding_widgets/onboarding_page_2.dart';
import 'onboarding_widgets/onboarding_page_3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _snackbarShown = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, _) {
          _handleViewModelSideEffects(context, viewModel);

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _OnboardingDots(currentStep: viewModel.currentStep),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: viewModel.goToStep,
                      children: [
                        OnboardingPageOne(
                          key: const ValueKey('onboardingPage1'),
                          onContinue: viewModel.next,
                          onSkip: viewModel.skip,
                        ),
                        OnboardingPageTwo(
                          key: const ValueKey('onboardingPage2'),
                          onNext: viewModel.next,
                          onSkip: viewModel.skip,
                        ),
                        OnboardingPageThree(
                          key: const ValueKey('onboardingPage3'),
                          onGetStarted: viewModel.next,
                          onSkip: viewModel.skip,
                        ),
                      ],
                    ),
                  ),
                  _ContinueButton()
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleViewModelSideEffects(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      if (!mounted) return;

      if (viewModel.hasCompleted && !_snackbarShown) {
        _snackbarShown = true;
        // 🔹 Mark onboarding as seen
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenOnboarding', true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        );
      }

      if (_pageController.hasClients &&
          _pageController.page?.round() != viewModel.currentStep) {
        _pageController.animateToPage(
          viewModel.currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(OnboardingViewModel.totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.white38,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
final lastStep=viewModel.currentStep==OnboardingViewModel.totalSteps-1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          PrimaryButton(
            label: lastStep? 'Get Started' : 'Continue',
            onPressed: viewModel.next,      // uses SAME viewmodel
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: viewModel.skip,
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
