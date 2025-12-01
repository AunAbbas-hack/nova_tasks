class StatsModel {
  const StatsModel({
    required this.completedCount,
    required this.totalCount,
    required this.weeklyStreak,
    required this.monthlyStreak,
  });

  final int completedCount;
  final int totalCount;
  final int weeklyStreak;
  final int monthlyStreak;

  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      completedCount: json['completedCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      weeklyStreak: json['weeklyStreak'] as int? ?? 0,
      monthlyStreak: json['monthlyStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'completedCount': completedCount,
    'totalCount': totalCount,
    'weeklyStreak': weeklyStreak,
    'monthlyStreak': monthlyStreak,
  };

  StatsModel copyWith({
    int? completedCount,
    int? totalCount,
    int? weeklyStreak,
    int? monthlyStreak,
  }) {
    return StatsModel(
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      weeklyStreak: weeklyStreak ?? this.weeklyStreak,
      monthlyStreak: monthlyStreak ?? this.monthlyStreak,
    );
  }
}





