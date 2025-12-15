import 'package:flutter/material.dart';
import 'package:nova_tasks/core/theme/app_colors.dart';

class OnboardingPageOne extends StatelessWidget {
  const OnboardingPageOne({
    required this.onContinue,
    required this.onSkip,
    super.key,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const _FeatureCard(),
          const SizedBox(height: 40),
          Text(
            'Effortless Task Creation',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quickly add, organize, and manage your daily to-dos in one place.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const Spacer(),
          // PrimaryButton(label: 'Continue', onPressed: onContinue),
          // const SizedBox(height: 12),
          // TextButton(onPressed: onSkip, child: const Text('Skip')),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 24),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        children: const [
          _Badge(),
          SizedBox(height: 32),
          _TaskRow(isActive: false),
          SizedBox(height: 16),
          _TaskRow(isActive: true),
          SizedBox(height: 16),
          _TaskRow(isActive: false),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,

          ),
          child:  Icon(
            Icons.task_alt_rounded,
            size: 36,
            color: primary ,
          ),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final background = isActive
        ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.surface;
    final bulletColor = isActive ? AppColors.primary : AppColors.mutedGrey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bulletColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.mutedGrey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
