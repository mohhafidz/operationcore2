class TargetAchievementUIState {
  final List<String> availableFilters;
  final String activeFilter;
  final String totalRevenueStr;
  final String trendPercentage;
  final List<double> chartPoints;
  final List<double> targetPoints;
  final List<Map<String, dynamic>> tableRows;
  final Map<String, dynamic> monthlyTotal;
  final List<Map<String, dynamic>> weeklyRows;
  final Map<String, dynamic> weeklyAverage;
  final Map<String, dynamic> weeklySummary;

  TargetAchievementUIState({
    required this.availableFilters,
    required this.activeFilter,
    required this.totalRevenueStr,
    required this.trendPercentage,
    required this.chartPoints,
    required this.targetPoints,
    required this.tableRows,
    required this.monthlyTotal,
    required this.weeklyRows,
    required this.weeklyAverage,
    required this.weeklySummary,
  });
}
