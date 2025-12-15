import 'package:flutter/material.dart';
import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/l10n/app_localizations_en.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodels/recurrence_bottomsheet_viewmodel.dart';

Future<RecurrenceSettings?> showRecurrenceBottomSheet(
    BuildContext context, {
      RecurrenceSettings? initial,
    }) {
  return showModalBottomSheet<RecurrenceSettings>(

    context: context,
    backgroundColor: const Color(0xFF11151F),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return ChangeNotifierProvider(
        create: (_) => RecurrenceViewModel(initial: initial),
        child: const _RecurrenceSheetView(),
      );
    },
  );
}

class _RecurrenceSheetView extends StatelessWidget {
  const _RecurrenceSheetView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecurrenceViewModel>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final loc=AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: bottomInset + 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  width: 75,
                  decoration: BoxDecoration(
                    color: AppColors.elevatedCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:  AppText(loc.cancelAction,color: Colors.white,)
                  ),
                ),
                 Text(
                  loc.recurrenceSetTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  height: 40,
                  width: 75,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(

                    onPressed: () =>
                        Navigator.pop(context, vm.settings), // ✅ return settings
                    child:  AppText(loc.saveAction,color: Colors.white,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---------- Tabs (Daily / Weekly / Monthly / Yearly) ----------
            _FrequencyTabs(),

            const SizedBox(height: 16),

            // ---------- Content per frequency ----------
            _FrequencyContent(),

            const SizedBox(height: 16),

            // ---------- Ends section ----------
            _EndsSection(),

            const SizedBox(height: 16),

            // ---------- Summary ----------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                vm.summary,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecurrenceViewModel>();
    final freq = vm.frequency;
    final loc=AppLocalizations.of(context)!;
    Widget pill(String label, RecurrenceFrequency value) {
      final selected = freq == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => vm.setFrequency(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1D2939) : const Color(0xFF0B101A),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          pill(loc.recurrenceDaily, RecurrenceFrequency.daily),
          pill(loc.recurrenceWeekly, RecurrenceFrequency.weekly),
          pill(loc.recurrenceMonthly, RecurrenceFrequency.monthly),
          pill(loc.recurrenceYearly, RecurrenceFrequency.yearly),
        ],
      ),
    );
  }
}

class _FrequencyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecurrenceViewModel>();
    final loc=AppLocalizations.of(context)!;
    switch (vm.frequency) {
      case RecurrenceFrequency.daily:
        return  Align(
          alignment: Alignment.centerLeft,
          child: Text(
            loc.recurrenceDailyDesc,
            style: TextStyle(color: Colors.white70),
          ),
        );
      case RecurrenceFrequency.weekly:
        return const _WeeklySelector();
      case RecurrenceFrequency.monthly:
        return  Align(
          alignment: Alignment.centerLeft,
          child: Text(
            loc.recurrenceMonthlyDesc,
            style: TextStyle(color: Colors.white70),
          ),
        );
      case RecurrenceFrequency.yearly:
        return  Align(
          alignment: Alignment.centerLeft,
          child: Text(
            loc.recurrenceYearlyDesc,
            style: TextStyle(color: Colors.white70),
          ),
        );
    }
  }
}

class _WeeklySelector extends StatelessWidget {
  const _WeeklySelector();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecurrenceViewModel>();
    final selected = vm.weekDays;
    final loc=AppLocalizations.of(context)!;
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const weekdays = [7, 1, 2, 3, 4, 5, 6]; // start from Sunday for UI

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          loc.recurrenceRepeatsOn,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final wd = weekdays[index];
            final isSel = selected.contains(wd);
            return GestureDetector(
              onTap: () => vm.toggleWeekday(wd),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSel ? Colors.blue : const Color(0xFF1A1E28),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isSel ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _EndsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecurrenceViewModel>();
    final endType = vm.endType;
    final loc=AppLocalizations.of(context)!;
    Widget radioTile(String title, RecurrenceEndType type,
        {Widget? trailing}) {
      final selected = endType == type;
      return InkWell(
        onTap: () => vm.setEndType(type),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? Colors.blue : Colors.white54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          loc.recurrenceEnds,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        radioTile(loc.recurrenceForever, RecurrenceEndType.never),
        radioTile(
          loc.recurrenceUntil,
          RecurrenceEndType.onDate,
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white70),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: vm.endDate ?? now,
                firstDate: now,
                lastDate: DateTime(now.year + 5),
              );
              if (picked != null) {
                vm.setEndDate(picked);
              }
            },
          ),
        ),
        radioTile(
         loc.recurrenceAfterOccurrences,
          RecurrenceEndType.afterCount,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white70),
                onPressed: () {
                  final current = vm.endCount ?? 10;
                  vm.setEndCount(current - 1);
                },
              ),
              Text(
                '${vm.endCount ?? 10}',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white70),
                onPressed: () {
                  final current = vm.endCount ?? 10;
                  vm.setEndCount(current + 1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
