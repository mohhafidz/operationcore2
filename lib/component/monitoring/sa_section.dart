import 'package:flutter/material.dart';
import 'package:operationcore2/component/monitoring/sa_card.dart';
import 'package:operationcore2/model/monitoringSAmodel.dart';

/// Section yang menampilkan semua SA dalam satu baris (Row)
class SaSection extends StatelessWidget {
  final List<monitoringSAmodel> data;
  final int workingDay;

  const SaSection({super.key, required this.data, required this.workingDay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: data.map((sa) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SaCard(data: sa, workingDay: workingDay),
          ),
        );
      }).toList(),
    );
  }
}
