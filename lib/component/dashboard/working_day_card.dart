import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/component/shared/app_text.dart';
import 'package:operationcore2/component/shared/currency_input_field.dart';

/// Card khusus menampilkan jumlah hari kerja dengan field angka besar
/// Digunakan di Dashboard header
class WorkingDayCard extends StatelessWidget {
  final TextEditingController controller;

  const WorkingDayCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CardCustume(
      padding: 40,
      widget: Column(
        children: [
          const AppTextLabel("JML Hari Kerja"),
          NumberDisplayField(controller: controller, enabled: false),
        ],
      ),
    );
  }
}

/// Card kecil untuk UNIT ENTRY dengan angka besar
/// Digunakan di SAperformance header
class UnitEntryCard extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;

  const UnitEntryCard({
    super.key,
    required this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return CardCustume(
      padding: 40,
      widget: Column(
        children: [
          const AppTextLabel("UNIT ENTRY"),
          NumberDisplayField(
            controller: controller,
            enabled: !readOnly,
          ),
        ],
      ),
    );
  }
}
