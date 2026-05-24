class TargetAchievementUIState {
  final List<String> availableFilters;
  final String activeFilter;
  final String totalRevenueStr;
  final String trendPercentage;
  final List<double> chartPoints;
  final List<double> targetPoints;
  final List<Map<String, dynamic>> tableRows;
  final Map<String, dynamic> monthlyTotal;

  TargetAchievementUIState({
    required this.availableFilters,
    required this.activeFilter,
    required this.totalRevenueStr,
    required this.trendPercentage,
    required this.chartPoints,
    required this.targetPoints,
    required this.tableRows,
    required this.monthlyTotal,
  });
}
