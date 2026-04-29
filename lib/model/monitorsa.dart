import 'package:flutter/material.dart';

class MonitoringSA {
  final String name;
  final double achievement;
  final List<ProgressItem> progress;
  final revperunit metric;

  MonitoringSA({
    required this.name,
    required this.achievement,
    required this.progress,
    required this.metric,
  });
}

class ProgressItem {
  final String label;
  final int current;
  final int target;
  final Color color;

  ProgressItem({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });
}

class revperunit {
  final String lc;
  final String oil;
  final String sparepart;
  final String suborder;
  final String submaterial;
  final String revenue;

  revperunit({
    required this.lc,
    required this.oil,
    required this.sparepart,
    required this.suborder,
    required this.submaterial,
    required this.revenue,
  });
}
