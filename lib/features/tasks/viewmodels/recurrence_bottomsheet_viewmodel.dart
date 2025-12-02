import 'package:flutter/material.dart';

/// Frequency (tab bar)
enum RecurrenceFrequency { daily, weekly, monthly, yearly }

/// How the recurrence ends
enum RecurrenceEndType { never, onDate, afterCount }

/// Settings object that you will store in your TaskModel later
class RecurrenceSettings {
  final RecurrenceFrequency frequency;
  final Set<int> weekDays; // 1=Mon ... 7=Sun
  final RecurrenceEndType endType;
  final DateTime? endDate;
  final int? endCount;

  const RecurrenceSettings({
    required this.frequency,
    this.weekDays = const {},
    this.endType = RecurrenceEndType.never,
    this.endDate,
    this.endCount,
  });

  RecurrenceSettings copyWith({
    RecurrenceFrequency? frequency,
    Set<int>? weekDays,
    RecurrenceEndType? endType,
    DateTime? endDate,
    int? endCount,
  }) {
    return RecurrenceSettings(
      frequency: frequency ?? this.frequency,
      weekDays: weekDays ?? this.weekDays,
      endType: endType ?? this.endType,
      endDate: endDate ?? this.endDate,
      endCount: endCount ?? this.endCount,
    );
  }
}

/// ViewModel only for bottom sheet UI
class RecurrenceViewModel extends ChangeNotifier {
  RecurrenceViewModel({RecurrenceSettings? initial})
      : _settings = initial ??
      const RecurrenceSettings(
        frequency: RecurrenceFrequency.daily,
        weekDays: {},
        endType: RecurrenceEndType.never,
      );

  RecurrenceSettings _settings;
  RecurrenceSettings get settings => _settings;

  RecurrenceFrequency get frequency => _settings.frequency;
  Set<int> get weekDays => _settings.weekDays;
  RecurrenceEndType get endType => _settings.endType;
  DateTime? get endDate => _settings.endDate;
  int? get endCount => _settings.endCount;

  // ---- actions ----

  void setFrequency(RecurrenceFrequency f) {
    _settings = _settings.copyWith(frequency: f);
    notifyListeners();
  }

  void toggleWeekday(int weekday) {
    final updated = {...weekDays};
    if (updated.contains(weekday)) {
      updated.remove(weekday);
    } else {
      updated.add(weekday);
    }
    _settings = _settings.copyWith(weekDays: updated);
    notifyListeners();
  }

  void setEndType(RecurrenceEndType t) {
    _settings = _settings.copyWith(endType: t);
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _settings = _settings.copyWith(endDate: date, endType: RecurrenceEndType.onDate);
    notifyListeners();
  }

  void setEndCount(int count) {
    if (count < 1) return;
    _settings = _settings.copyWith(endCount: count, endType: RecurrenceEndType.afterCount);
    notifyListeners();
  }

  String get summary {
    final buffer = StringBuffer('Repeats ');

    // Frequency
    switch (frequency) {
      case RecurrenceFrequency.daily:
        buffer.write('daily');
        break;
      case RecurrenceFrequency.weekly:
        if (weekDays.isEmpty) {
          buffer.write('weekly');
        } else {
          const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final list = weekDays.toList()..sort();
          final days = list.map((w) => names[w - 1]).join(', ');
          buffer.write('every $days');
        }
        break;
      case RecurrenceFrequency.monthly:
        buffer.write('monthly');
        break;
      case RecurrenceFrequency.yearly:
        buffer.write('yearly');
        break;
    }

    // End text
    switch (endType) {
      case RecurrenceEndType.never:
        buffer.write(', forever.');
        break;
      case RecurrenceEndType.onDate:
        if (endDate != null) {
          buffer.write(' until '
              '${endDate!.day}/${endDate!.month}/${endDate!.year}.');
        }
        break;
      case RecurrenceEndType.afterCount:
        if (endCount != null) {
          buffer.write(', for $endCount occurrences.');
        }
        break;
    }

    return buffer.toString();
  }
}
