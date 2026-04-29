import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/model/tabledetailperformance.dart';

/// Satu baris tabel breakdown performa (Dashboard Detail Performance Table)
class DetailTableRow extends StatelessWidget {
  final String metric;
  final List<TableValue> values;
  final bool isHeader;
  final Color? color;
  final bool dynamicColor;

  const DetailTableRow({
    super.key,
    required this.metric,
    required this.values,
    this.isHeader = false,
    this.color,
    this.dynamicColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(.05)),
        ),
      ),
      child: Row(
        children: [
          /// METRIC COLUMN
          Expanded(
            flex: 2,
            child: Text(
              metric,
              style: GoogleFonts.inter(
                fontSize: isHeader ? 12 : 13,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                color: const Color(0xff94A3B8),
              ),
            ),
          ),

          /// VALUE COLUMNS
          ...values.map((value) {
            return Expanded(
              child: Center(
                child: DetailTableCell(
                  value: value.value,
                  detail: value.detail,
                  isHeader: isHeader,
                  baseColor: color,
                  dynamicColor: dynamicColor,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Cell dalam tabel breakdown, mendukung warna dinamis, trend icon, dan detail sub-value
class DetailTableCell extends StatelessWidget {
  final String value;
  final String? detail;
  final bool isHeader;
  final Color? baseColor;
  final bool dynamicColor;

  const DetailTableCell({
    super.key,
    required this.value,
    this.detail,
    this.isHeader = false,
    this.baseColor,
    this.dynamicColor = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHeader) {
      return Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    /// TREND ICONS
    if (value == "up") {
      return const Icon(Icons.trending_up, size: 18, color: Color(0xff10B981));
    }
    if (value == "down") {
      return const Icon(Icons.trending_down, size: 18, color: Color(0xffF43F5E));
    }

    Color textColor = Colors.white;

    if (baseColor != null) {
      textColor = baseColor!;
    }

    if (dynamicColor) {
      final match = RegExp(r'-?\d+\.?\d*').firstMatch(value);
      final number = double.tryParse(match?.group(0) ?? "0") ?? 0;
      textColor = number < 0 ? const Color(0xffF43F5E) : const Color(0xff10B981);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (detail != null)
          Text(
            detail!,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xff64748B),
            ),
          ),
      ],
    );
  }
}
