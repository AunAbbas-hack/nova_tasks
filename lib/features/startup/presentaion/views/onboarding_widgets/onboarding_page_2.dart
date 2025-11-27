import 'package:flutter/material.dart';
import 'package:nova_tasks/core/theme/app_colors.dart';
import 'package:nova_tasks/core/widgets/primary_button.dart';

class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({
    required this.onNext,
    required this.onSkip,
    super.key,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [


          const _CalendarPreview(),
          const SizedBox(height: 40),
          Text(
            'Visualize Your Week\nat a Glance',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'See your tasks directly on a calendar to help with planning and keep an eye on upcoming deadlines.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          // const SizedBox(height: 24),
          const Spacer(),
          // PrimaryButton(label: 'Next', onPressed: onNext),
          // Align(
          //   alignment: Alignment.center,
          //   child: TextButton(onPressed: onSkip, child: const Text('Skip')),
          // ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CalendarPreview extends StatelessWidget {
  const _CalendarPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: const [
          _CalendarCard(),
          Positioned(
            top: 10,
            left: 10,
            right: 20,
            child: _EventBubble(
              title: 'Design meeting',
              subtitle: '10:00 AM - 11:00 AM',
              accentColor: Color(0xFFFF66CC),
            ),
          ),
          Positioned(
            bottom: 36,
            right: 18,
            left: 24,
            child: _EventBubble(
              title: 'Finish Q2 report',
              subtitle: 'Due EOD',
              accentColor: AppColors.primary,
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (index) => 9 + index);
    final dotColors = <int, Color?>{
      10: AppColors.primaryBright,
      12: Colors.pinkAccent,
      13: AppColors.primary,
      18: Colors.greenAccent.shade100,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      padding: const EdgeInsets.fromLTRB(28, 80, 28, 32),
      child: Column(
        children: [
          Row(
            children: const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: days
                .map(
                  (day) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _CalendarDay(
                        value: day,
                        isSelected: day == 13,
                        dotColor: dotColors[day],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.value,
    this.isSelected = false,
    this.dotColor,
  });

  final int value;
  final bool isSelected;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      value.toString().padLeft(2, '0'),
      style: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: !isSelected
              ? Border.all(color: AppColors.subtleBorder)
              : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            text,
            if (dotColor != null) ...[
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventBubble extends StatelessWidget {
  const _EventBubble({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.alignment = Alignment.centerRight,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 32,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.subtleBorder,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
