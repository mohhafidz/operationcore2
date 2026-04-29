import 'package:flutter/material.dart';
import 'package:operationcore2/utils/number_formatter.dart';

/// Satu baris metrik dengan label dan nilai
class MetricRow extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const MetricRow({
    super.key,
    required this.title,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xff94A3B8))),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xff1E293B), height: 1),
      ],
    );
  }
}

/// Card yang menampilkan REV/UNIT per metrik (LC, Oil, Spare Part, dll.)
class MetricDetailsCard extends StatelessWidget {
  final double achievementLC;
  final double achievementOil;
  final double achievementSparePart;
  final double achievementSubOrder;
  final double achievementSubMaterial;
  final double achievementRevenue;

  const MetricDetailsCard({
    super.key,
    required this.achievementLC,
    required this.achievementOil,
    required this.achievementSparePart,
    required this.achievementSubOrder,
    required this.achievementSubMaterial,
    required this.achievementRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff0F1B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff334155)),
      ),
      child: Column(
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: const Text(
              "REV/UNIT",
              style: TextStyle(
                color: Color(0xff94A3B8),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),

          const Divider(color: Color(0xff334155), height: 1),

          MetricRow(title: "LC", value: formatDecimal(achievementLC)),
          MetricRow(title: "Oil", value: formatDecimal(achievementOil)),
          MetricRow(title: "Spare Part", value: formatDecimal(achievementSparePart)),
          MetricRow(title: "Sub Order", value: formatDecimal(achievementSubOrder)),
          MetricRow(title: "Sub Material", value: formatDecimal(achievementSubMaterial)),
          MetricRow(title: "Revenue", value: formatDecimal(achievementRevenue)),
        ],
      ),
    );
  }
}
