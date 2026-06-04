import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:operationcore2/model/target_achievement_model.dart';

class RevenueTrendCard extends StatefulWidget {
  final TargetAchievementUIState saData;

  const RevenueTrendCard({super.key, required this.saData});

  @override
  State<RevenueTrendCard> createState() => _RevenueTrendCardState();
}

class _RevenueTrendCardState extends State<RevenueTrendCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;
  int? _hoveredIndex;
  double? _hoveredX;

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    );
    // Listen to animation progress to trigger repaint
    _chartAnimationController.addListener(() {
      setState(() {});
    });
    _chartAnimationController.forward();
  }

  @override
  void didUpdateWidget(covariant RevenueTrendCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.saData.activeFilter != widget.saData.activeFilter) {
      _chartAnimationController.reset();
      _chartAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRevenue = widget.saData.chartPoints.isNotEmpty
        ? widget.saData.chartPoints[_hoveredIndex ??
              (widget.saData.chartPoints.length - 1)]
        : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Stats & Legend Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DAILY REVENUE TREND",
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        NumberFormat.currency(
                          symbol: "Rp",
                          decimalDigits: 0,
                        ).format(currentRevenue),
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF38BDF8),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.saData.trendPercentage,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF10B981),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Legend row
              Row(
                children: [
                  _buildLegendItem(
                    "ACTUAL",
                    const Color(0xFF38BDF8),
                    isDotted: false,
                  ),
                  const SizedBox(width: 24.0),
                ],
              ),
            ],
          ),
          const SizedBox(height: 36.0),

          // Custom Chart Canvas with animated height scaling and hover interaction
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Tooltip positioned over hovered point
                  if (_hoveredIndex != null && _hoveredX != null) ...[
                    Positioned(
                      left: (_hoveredX! - 40).clamp(0.0, chartWidth - 80),
                      top: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.saData.chartLabels[_hoveredIndex!],
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                NumberFormat.currency(
                                  symbol: "Rp",
                                  decimalDigits: 0,
                                ).format(
                                  (() {
                                    final idx = _hoveredIndex!.clamp(
                                      0,
                                      widget.saData.chartPoints.length - 1,
                                    );
                                    return widget.saData.chartPoints[idx];
                                  })(),
                                ),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Chart with hover detection
                  MouseRegion(
                    onHover: (event) {
                      final local = event.localPosition;
                      final dx = local.dx.clamp(0.0, chartWidth);
                      final pointsCount = widget.saData.chartPoints.length;
                      final stepX = pointsCount > 1
                          ? chartWidth / (pointsCount - 1)
                          : chartWidth;
                      int index = (dx / stepX).round();
                      if (index < 0) index = 0;
                      if (index >= pointsCount) index = pointsCount - 1;
                      setState(() {
                        _hoveredIndex = index;
                        _hoveredX = (index * stepX).clamp(0.0, chartWidth);
                      });
                    },
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: SizedBox(
                      height: 260.0,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: RevenueChartPainter(
                          actualPoints: widget.saData.chartPoints,
                          animationValue: _chartAnimation.value,
                          hoveredIndex: _hoveredIndex,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12.0),

          // Timeline Labels
          _buildTimelineLabels(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, {required bool isDotted}) {
    return Row(
      children: [
        if (isDotted)
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLabels() {
    final labels = widget.saData.chartLabels;
    if (labels.isEmpty) return const SizedBox.shrink();

    final List<String> visibleLabels;
    if (labels.length <= 5) {
      visibleLabels = labels;
    } else {
      final int lastIndex = labels.length - 1;
      final positions = [
        0,
        (labels.length * 1 ~/ 4).clamp(0, lastIndex),
        (labels.length * 2 ~/ 4).clamp(0, lastIndex),
        (labels.length * 3 ~/ 4).clamp(0, lastIndex),
        lastIndex,
      ];
      visibleLabels = positions.map((idx) => labels[idx]).toSet().toList();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: visibleLabels.map((label) {
        return Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF475569),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList(),
    );
  }
}

// MARK: - Premium Custom Line Chart Painter
class RevenueChartPainter extends CustomPainter {
  final List<double> actualPoints;
  final double animationValue;
  final int? hoveredIndex;

  RevenueChartPainter({
    required this.actualPoints,
    required this.animationValue,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw Grid Lines (horizontal only)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    final double gridSpacing = height / 5;
    for (int i = 1; i < 5; i++) {
      final double y = gridSpacing * i;
      _drawDashedLine(
        canvas,
        Offset(0, y),
        Offset(width, y),
        gridPaint,
        dashLength: 6,
        gapLength: 4,
      );
    }

    if (actualPoints.isEmpty) return;

    final int pointCount = actualPoints.length;
    final double stepX = width / (pointCount - 1);

    // Get max point to scale the chart dynamically
    double maxVal = 1.0;
    for (var p in actualPoints) {
      if (p > maxVal) maxVal = p;
    }
    maxVal *= 1.15; // Give 15% breathing room at the top

    // 2. Draw Actual Revenue Trend Line with Smooth Bezier Curves
    final actualPath = Path();
    final fillPath = Path();

    final List<Offset> points = [];
    for (int i = 0; i < actualPoints.length; i++) {
      final double x = i * stepX;
      final double currentY =
          height - ((actualPoints[i] * animationValue) / maxVal) * height;

      points.add(Offset(x, currentY));
    }

    if (points.isNotEmpty) {
      actualPath.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];

        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;

        actualPath.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          p1.dx,
          p1.dy,
        );
        fillPath.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          p1.dx,
          p1.dy,
        );
      }

      fillPath.lineTo(points.last.dx, height);
      fillPath.lineTo(points.first.dx, height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF0D6EFD).withOpacity(0.24 * animationValue),
            const Color(0xFF0D6EFD).withOpacity(0.00),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, width, height));

      canvas.drawPath(fillPath, fillPaint);

      final glowPaint = Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.4)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..imageFilter = ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0);
      canvas.drawPath(actualPath, glowPaint);

      final linePaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(actualPath, linePaint);

      // Draw hover dot if index provided
      if (hoveredIndex != null && hoveredIndex! < points.length) {
        final hoverPoint = points[hoveredIndex!];
        final hoverOuterPaint = Paint()
          ..color = const Color(0xFF38BDF8).withOpacity(0.3)
          ..style = PaintingStyle.fill;
        final hoverInnerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(hoverPoint, 6, hoverOuterPaint);
        canvas.drawCircle(hoverPoint, 2.5, hoverInnerPaint);
      }

      if (points.isNotEmpty && animationValue > 0.8) {
        final lastPoint = points.last;
        final outerCirclePaint = Paint()
          ..color = const Color(0xFF38BDF8).withOpacity(0.3)
          ..style = PaintingStyle.fill;
        final innerCirclePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(lastPoint, 8, outerCirclePaint);
        canvas.drawCircle(lastPoint, 3.5, innerCirclePaint);
      }
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = (end - start).distance;
    if (distance == 0) return;

    final double cosTheta = dx / distance;
    final double sinTheta = dy / distance;

    double currentDist = 0.0;
    while (currentDist < distance) {
      final double endDash = (currentDist + dashLength).clamp(0.0, distance);
      canvas.drawLine(
        Offset(
          start.dx + currentDist * cosTheta,
          start.dy + currentDist * sinTheta,
        ),
        Offset(start.dx + endDash * cosTheta, start.dy + endDash * sinTheta),
        paint,
      );
      currentDist += dashLength + gapLength;
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final PathMetrics metrics = path.computeMetrics();
    for (PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = (distance + dashLength).clamp(0.0, metric.length);
        final Path extract = metric.extractPath(distance, length);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RevenueChartPainter oldDelegate) {
    return oldDelegate.actualPoints != actualPoints ||
        oldDelegate.animationValue != animationValue;
  }
}
