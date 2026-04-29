class DashboardCalculations {
  /// Calculate metrics for a single metric column (e.g. SIU, JASA, etc.)
  static MetricResults calculateMetric({
    required num actual,
    required num target,
    required num prevMonth,
    required num prevYear,
    required int totalWorkingDays,
    required int daysElapsed,
    required int remainingWorkingDays,
  }) {
    // 1. Percentage Achievement (TOTAL / TARGET)
    double achievementPercentage = (target != 0) ? (actual / target) * 100 : 0;

    // 2. Average Per Hari (Actual / Days Elapsed)
    // Avoid division by zero
    double averagePerHari = (daysElapsed > 0) ? (actual / daysElapsed) : 0;

    // 3. Sisa Target Ke 100% (Target - Actual)
    double sisaTargetValue = (target - actual).toDouble();

    // 4. Sisa Target / Hari (Sisa / Remaining Working Days)
    double sisaTargetPerHari = (remainingWorkingDays > 0) ? (sisaTargetValue / remainingWorkingDays) : 0;

    // 5. Maks Achv Based on Average (Actual + (Average * Remaining Days))
    double maksAchvValue = actual + (averagePerHari * remainingWorkingDays);

    // 6. Maks Achv (%) (Maks / Target)
    double maksAchvPercentage = (target != 0) ? (maksAchvValue / target) * 100 : 0;

    // 7. Target Harian Minimal (Budget) (Target / Total Working Days)
    double dailyBudget = (totalWorkingDays > 0) ? (target / totalWorkingDays) : 0;

    // 8. Growth vs Previous Month
    double growthMonth = (prevMonth != 0) ? ((actual - prevMonth) / prevMonth) * 100 : 0;

    // 9. Growth vs Previous Year
    double growthYear = (prevYear != 0) ? ((actual - prevYear) / prevYear) * 100 : 0;

    return MetricResults(
      achievementPercentage: achievementPercentage,
      averagePerHari: averagePerHari,
      sisaTargetValue: sisaTargetValue,
      sisaTargetPerHari: sisaTargetPerHari,
      maksAchvValue: maksAchvValue,
      maksAchvPercentage: maksAchvPercentage,
      dailyBudget: dailyBudget,
      growthMonth: growthMonth,
      growthYear: growthYear,
    );
  }
}

class MetricResults {
  final double achievementPercentage;
  final double averagePerHari;
  final double sisaTargetValue;
  final double sisaTargetPerHari;
  final double maksAchvValue;
  final double maksAchvPercentage;
  final double dailyBudget;
  final double growthMonth;
  final double growthYear;

  MetricResults({
    required this.achievementPercentage,
    required this.averagePerHari,
    required this.sisaTargetValue,
    required this.sisaTargetPerHari,
    required this.maksAchvValue,
    required this.maksAchvPercentage,
    required this.dailyBudget,
    required this.growthMonth,
    required this.growthYear,
  });
}
