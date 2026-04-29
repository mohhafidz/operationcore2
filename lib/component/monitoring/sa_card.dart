import 'package:flutter/material.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/component/monitoring/circular_achievement.dart';
import 'package:operationcore2/component/monitoring/metric_details_card.dart';
import 'package:operationcore2/component/monitoring/metric_progress_bar.dart';
import 'package:operationcore2/component/monitoring/sa_avatar.dart';
import 'package:operationcore2/component/monitoring/stacked_bar_card.dart';
import 'package:operationcore2/model/monitoringSAmodel.dart';

/// Card lengkap untuk satu SA, menampilkan semua data performa
class SaCard extends StatelessWidget {
  final monitoringSAmodel data;
  final int workingDay;

  const SaCard({super.key, required this.data, required this.workingDay});

  @override
  Widget build(BuildContext context) {
    final entry = data.entry;
    final target = data.target;

    final double day = workingDay > 0 ? workingDay.toDouble() : 1.0;

    final double actSiu = entry.siu / day;
    final double actLc = entry.lc / day;
    final double actOil = entry.oil / day;
    final double actSpart = entry.spart / day;
    final double actSo = entry.so / day;
    final double actSm = entry.sm / day;
    final double actRevenue = entry.revenue / day;

    // Total achievement dihitung sebagai jumlah individual yang di-clamp
    // agar over-performance satu kategori tidak menutupi under-performance kategori lain
    final int totalClamped =
        (entry.lc.clamp(0, target.lc)) +
        (entry.oil.clamp(0, target.oil)) +
        (entry.spart.clamp(0, target.sparepart)) +
        (entry.so.clamp(0, target.sorder)) +
        (entry.sm.clamp(0, target.smaterial));

    final double achievement = target.revenue == 0
        ? 0.0
        : ((totalClamped / target.revenue) * 100).toDouble();

    /// REV/UNIT per metrik
    final double achievementLC = entry.lc == 0
        ? 0.0
        : (entry.siu == 0 ? 0.0 : ((entry.lc / entry.siu) * 1).toDouble());

    final double achievementOil = entry.oil == 0
        ? 0.0
        : (entry.siu == 0 ? 0.0 : ((entry.oil / entry.siu) * 1).toDouble());

    final double achievementSparePart = entry.spart == 0
        ? 0.0
        : (entry.siu == 0 ? 0.0 : ((entry.spart / entry.siu) * 1).toDouble());

    final double achievementSubOrder = entry.so == 0
        ? 0.0
        : (entry.siu == 0 ? 0.0 : ((entry.so / entry.siu) * 1).toDouble());

    final double achievementSubMaterial = entry.sm == 0
        ? 0.0
        : (entry.siu == 0 ? 0.0 : ((entry.sm / entry.siu) * 1).toDouble());

    final double achievementRevenue = entry.revenue == 0
        ? 0.0
        : (entry.siu == 0 ? 0.0 : ((entry.revenue / entry.siu) * 1).toDouble());

    return CardCustume(
      padding: 16,
      widget: Column(
        children: [
          SaAvatar(name: data.sa.name),

          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

          CircularAchievement(
            percentage: achievement,
            label: "TOTAL ACHIEVEMENT",
          ),

          const SizedBox(height: 16),

          MetricProgressBar(
            current: entry.siu,
            target: target.siu,
            label: "SIU",
            color: const Color(0xFF3B82F6),
          ),
          MetricProgressBar(
            current: entry.lc,
            target: target.lc,
            label: "LC",
            color: const Color(0xFF3B82F6),
          ),
          MetricProgressBar(
            current: entry.oil,
            target: target.oil,
            label: "Oil",
            color: const Color(0xFF3B82F6),
          ),
          MetricProgressBar(
            current: entry.spart,
            target: target.sparepart,
            label: "Spare Part",
            color: const Color(0xFF3B82F6),
          ),
          MetricProgressBar(
            current: entry.so,
            target: target.sorder,
            label: "Sub Order",
            color: const Color(0xFF3B82F6),
          ),
          MetricProgressBar(
            current: entry.sm,
            target: target.smaterial,
            label: "Sub Material",
            color: const Color(0xFF3B82F6),
          ),
          MetricProgressBar(
            current: entry.total,
            target: target.revenue,
            label: "Revenue",
            color: const Color(0xFF3B82F6),
          ),

          const SizedBox(height: 16),

          MetricDetailsCard(
            achievementLC: achievementLC,
            achievementOil: achievementOil,
            achievementSparePart: achievementSparePart,
            achievementSubOrder: achievementSubOrder,
            achievementSubMaterial: achievementSubMaterial,
            achievementRevenue: achievementRevenue,
          ),

          const SizedBox(height: 16),

          StackedBarCard(
            siu: actSiu,
            lc: actLc,
            oil: actOil,
            sparePart: actSpart,
            subOrder: actSo,
            subMaterial: actSm,
            revenue: actRevenue,
          ),
        ],
      ),
    );
  }
}
