import 'package:operationcore2/model/alluser.dart';
import 'package:operationcore2/model/sa_entry.dart';
import 'package:operationcore2/model/target_model.dart';

class monitoringSAmodel {
  final alluser sa;
  final SAEntry entry;
  final TargetModel target;

  monitoringSAmodel({
    required this.sa,
    required this.entry,
    required this.target,
  });

  int get totalPenjualan => entry.total;

  double get achievement {
    if (target.revenue == 0) return 0.0;
    // Calculate clamped total to ensure over-performance in one area
    // doesn't hide under-performance in others for the total percentage.
    final int totalClamped = (entry.lc.clamp(0, target.lc)) +
        (entry.oil.clamp(0, target.oil)) +
        (entry.spart.clamp(0, target.sparepart)) +
        (entry.so.clamp(0, target.sorder)) +
        (entry.sm.clamp(0, target.smaterial));

    return (totalClamped / target.revenue) * 100;
  }
}
