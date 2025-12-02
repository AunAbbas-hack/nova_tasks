import 'package:flutter/material.dart';
import 'package:nova_tasks/core/theme/app_colors.dart';

class OnboardingPageThree extends StatelessWidget {
  const OnboardingPageThree({
    required this.onGetStarted,
    required this.onSkip,
    super.key,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const _StatsPreview(),
          const SizedBox(height: 40),
          Text(
            'Track Your Progress,\nVisually.',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Get insights into your habits, See completion rates, and discover your most productive days.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const Spacer(),

        ],
      ),
    );
  }
}

class _StatsPreview extends StatelessWidget {
  const _StatsPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: 280,
        color: const Color(0xFF58B7A1),
        child: Center(
          child: Container(
            width: 220,
            height: 240,
      decoration: BoxDecoration(
              color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
            padding: const EdgeInsets.all(16),
        child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BarLine(height: 18, widthFactor: 0.8),
                _DonutChart(),
                _BarLine(height: 12, widthFactor: 0.5),
                _BarLine(height: 12, widthFactor: 0.65),
                _BarLine(height: 12, widthFactor: 0.35),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarLine extends StatelessWidget {
  const _BarLine({required this.height, required this.widthFactor});

  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
        widthFactor: widthFactor,
          child: Container(
          height: height,
            decoration: BoxDecoration(
            color: const Color(0xFFE8EFFA),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFFA),
                shape: BoxShape.circle,
            ),
              ),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '87%',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              ),
            ),
          ],
      ),
    );
  }
}
