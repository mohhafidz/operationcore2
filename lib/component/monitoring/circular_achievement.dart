import 'package:flutter/material.dart';
import 'package:operationcore2/component/dashboard/circular_gauge.dart';

/// Widget Circular Progress dengan persentase dan label di bawahnya
/// Versi besar (size: 136) untuk card monitoring SA
/// Re-export CircularGauge dengan konfigurasi default monitoring
class CircularAchievement extends StatelessWidget {
  final double percentage;
  final String label;

  const CircularAchievement({
    super.key,
    required this.percentage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return CircularGauge(
      percentage: percentage,
      label: label,
      size: 136,
      strokeWidth: 8,
      labelOnTop: false,
    );
  }
}
