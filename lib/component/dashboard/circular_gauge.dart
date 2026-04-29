import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/component/shared/app_text.dart';

/// Card persentase besar dengan circular indicator + label (digunakan di Dashboard)
/// Ukuran lingkaran dapat dikustomisasi
class CircularGauge extends StatelessWidget {
  final double percentage;
  final String label;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final bool labelOnTop;

  const CircularGauge({
    super.key,
    required this.percentage,
    required this.label,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor = const Color(0xFF3B82F6),
    this.labelOnTop = true,
  });

  @override
  Widget build(BuildContext context) {
    final value = (percentage / 100).clamp(0.0, 1.0);

    return CardCustume(
      padding: 20,
      widget: Column(
        children: [
          if (labelOnTop) ...[
            AppTextLabel(label, fontSize: 10),
            const SizedBox(height: 10),
          ],
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "${percentage.round()}%",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: size * 0.225,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (!labelOnTop) ...[
            const SizedBox(height: 10),
            AppTextLabel(label, fontSize: 10),
          ],
        ],
      ),
    );
  }
}

/// Titik bulat berwarna (dot indicator) untuk legend/keterangan
class DotIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const DotIndicator({super.key, this.size = 8, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Row legend: titik berwarna + label
class LegendIndicator extends StatelessWidget {
  final String label;
  final Color color;

  const LegendIndicator({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DotIndicator(color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
