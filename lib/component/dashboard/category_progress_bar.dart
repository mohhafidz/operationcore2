import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/utils/number_formatter.dart';

/// Progress bar horizontal untuk kategori metric di Dashboard
/// Mendukung ukuran bar yang lebih besar (height: 22) dibanding MetricProgressBar monitoring
class CategoryProgressBar extends StatelessWidget {
  final int current;
  final int target;
  final String label;
  final Color color;
  final double barHeight;

  const CategoryProgressBar({
    super.key,
    required this.current,
    required this.target,
    required this.label,
    required this.color,
    this.barHeight = 22,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = target == 0
        ? 0.0
        : (current / target).clamp(0.0, 1.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: const Color(0xff94A3B8),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                if (target > 0) ...[
                  const SizedBox(width: 8),
                  _buildGapBadge(current, target),
                ],
              ],
            ),
            Text(
              "${numberFormatter.format(current)} / ${numberFormatter.format(target)}",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// PROGRESS BAR
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;

            return Stack(
              children: [
                /// Background Track
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xff0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                /// Progress Fill
                Container(
                  height: barHeight,
                  width: barWidth * progress.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                /// Target Indicator Line
                Positioned(
                  left: (target / (current == 0 ? 1 : current) <= 1
                          ? (target / (current == 0 ? 1 : current))
                          : 1) *
                      barWidth,
                  child: Container(
                    width: 2,
                    height: barHeight,
                    color: Colors.white24,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGapBadge(int current, int target) {
    final int gap = current - target;
    final bool isMinus = gap < 0;
    
    final Color bgColor = isMinus ? const Color(0xffF43F5E).withOpacity(0.15) : const Color(0xff10B981).withOpacity(0.15);
    final Color textColor = isMinus ? const Color(0xffF43F5E) : const Color(0xff10B981);
    
    final int absGap = gap.abs();
    final String formattedGap = numberFormatter.format(absGap);
    final String displayText = isMinus ? "-$formattedGap" : "+$formattedGap";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
