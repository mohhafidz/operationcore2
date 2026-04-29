import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/component/shared/app_text.dart';

/// Card performance dengan header berwarna, fields, dan optional subtotal
/// Digunakan di SAperformance (Penjualan, HPP, dll.)
/// Dapat digunakan ulang di fitur lain yang memerlukan form dalam card
class PerformanceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color headerColor;
  final List<Widget> fields;
  final String? subtotalTitle;
  final String? subtotalValue;
  final Color? subtotalColor;
  final bool showSubtotal;

  const PerformanceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.headerColor,
    required this.fields,
    this.subtotalTitle,
    this.subtotalValue,
    this.subtotalColor,
    this.showSubtotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return CardCustume(
      padding: 0,
      widget: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: headerColor),
                const SizedBox(width: 12),
                AppTextTitle(title, fontSize: 16),
              ],
            ),
          ),

          /// FIELDS
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Wrap(runSpacing: 16, spacing: 10, children: fields),
                if (showSubtotal && subtotalTitle != null) ...[
                  const SizedBox(height: 20),
                  _SubtotalInline(
                    title: subtotalTitle!,
                    value: subtotalValue ?? "0",
                    color: subtotalColor ?? headerColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtotalInline extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SubtotalInline({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xff94A3B8),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Rp $value",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
