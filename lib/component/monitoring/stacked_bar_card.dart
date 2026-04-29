import 'package:flutter/material.dart';
import 'package:operationcore2/component/monitoring/metric_details_card.dart';
import 'package:operationcore2/utils/number_formatter.dart';

/// Card Stacked Bar untuk menampilkan ACT/HARI per metrik
class StackedBarCard extends StatelessWidget {
  final double siu;
  final double lc;
  final double oil;
  final double sparePart;
  final double subOrder;
  final double subMaterial;
  final double revenue;

  const StackedBarCard({
    super.key,
    required this.siu,
    required this.lc,
    required this.oil,
    required this.sparePart,
    required this.subOrder,
    required this.subMaterial,
    required this.revenue,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              "ACT/HARI",
              style: TextStyle(
                color: Color(0xff94A3B8),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),

          const Divider(color: Color(0xff334155), height: 1),

          /// STACKED BAR
          // if (revenue > 0)
          //   Padding(
          //     padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(6),
          //       child: SizedBox(
          //         height: 12,
          //         child: Row(
          //           children: [
          //             if (lc > 0)
          //               Expanded(
          //                 flex: (lc * 100).toInt(),
          //                 child: Container(color: const Color(0xff10B981)),
          //               ),
          //             if (oil > 0)
          //               Expanded(
          //                 flex: (oil * 100).toInt(),
          //                 child: Container(color: const Color(0xff00F2FF)),
          //               ),
          //             if (sparePart > 0)
          //               Expanded(
          //                 flex: (sparePart * 100).toInt(),
          //                 child: Container(color: const Color(0xff3B82F6)),
          //               ),
          //             if (subOrder > 0)
          //               Expanded(
          //                 flex: (subOrder * 100).toInt(),
          //                 child: Container(color: const Color(0xff34D399)),
          //               ),
          //             if (subMaterial > 0)
          //               Expanded(
          //                 flex: (subMaterial * 100).toInt(),
          //                 child: Container(color: const Color(0xffF59E0B)),
          //               ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          MetricRow(title: "SIU", value: formatDecimal(siu)),
          MetricRow(title: "LC", value: formatDecimal(lc)),
          MetricRow(title: "Oil", value: formatDecimal(oil)),
          MetricRow(title: "Spare Part", value: formatDecimal(sparePart)),
          MetricRow(title: "Sub Order", value: formatDecimal(subOrder)),
          MetricRow(title: "Sub Material", value: formatDecimal(subMaterial)),
          MetricRow(title: "Revenue", value: formatDecimal(revenue)),
        ],
      ),
    );
  }
}
