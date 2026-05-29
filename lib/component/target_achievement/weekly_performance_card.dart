import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/model/target_achievement_model.dart';

class WeeklyPerformanceCard extends StatelessWidget {
  final TargetAchievementUIState saData;

  const WeeklyPerformanceCard({super.key, required this.saData});

  @override
  Widget build(BuildContext context) {
    final rows = saData.weeklyRows;
    final average = saData.weeklyAverage;
    final summary = saData.weeklySummary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF081426),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF2E3A57)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "WEEKLY PERFORMANCE",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            "AVERAGE PER WEEK",
            style: GoogleFonts.inter(
              color: const Color(0xFF7C9AFF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20.0),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: 1798,
                child: Column(
                  children: [
                    _buildTableHeader(),
                    const Divider(color: Color(0xFF2E3A57), height: 1.0),
                    Column(
                      children: rows.map((row) => _buildTableRow(row)).toList(),
                    ),
                    const Divider(color: Color(0xFF2E3A57), height: 1.0),
                    _buildAverageRow(average),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28.0),
          _buildWeeklySummaryStrip(rows),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: "AVG NET PROFIT",
                  value: summary['avgNetProfit'] ?? '-',
                  highlightColor: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildSummaryCard(
                  title: "AVG MARGIN",
                  value: summary['avgMargin'] ?? '-',
                  highlightColor: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildSummaryCard(
                  title: "PEAK MARGIN",
                  value: summary['peakMargin'] ?? '-',
                  highlightColor: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2040),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
        border: Border.all(color: const Color(0xFF2E3A57)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _headerCell("WEEK", Alignment.centerLeft)),
          Expanded(flex: 1, child: _headerCell("UNIT", Alignment.centerRight)),
          Expanded(flex: 2, child: _headerCell("JASA", Alignment.centerRight)),
          Expanded(flex: 2, child: _headerCell("OIL", Alignment.centerRight)),
          Expanded(
            flex: 2,
            child: _headerCell("S/PART", Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell("S/ORDER", Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell("MATERIAL", Alignment.centerRight),
          ),
          Expanded(flex: 3, child: _headerCell("TOTAL", Alignment.centerRight)),
          Expanded(flex: 2, child: _headerCell("NET", Alignment.centerRight)),
          Expanded(
            flex: 2,
            child: _headerCell("MARGIN", Alignment.centerRight),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> row) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _cellText(row['week'] ?? '', Alignment.centerLeft),
          ),
          Expanded(
            flex: 1,
            child: _cellText(
              row['unitEntry']?.toString() ?? '-',
              Alignment.centerRight,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['jasa'] ?? '-', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['oil'] ?? '-', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['spart'] ?? '-', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['sorder'] ?? '-', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['sm'] ?? '-', Alignment.centerRight),
          ),
          Expanded(
            flex: 3,
            child: _cellText(
              row['totalPenjualan'] ?? '-',
              Alignment.centerRight,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['profit'] ?? '-', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              row['profitPercent'] ?? '-',
              Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageRow(Map<String, dynamic> row) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEC7A1C).withOpacity(0.18),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _cellText(
              row['week'] ?? '',
              Alignment.centerLeft,
              isBold: true,
              color: const Color(0xFFEC7A1C),
            ),
          ),
          Expanded(
            flex: 1,
            child: _cellText(
              row['unitEntry']?.toString() ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              row['jasa'] ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              row['oil'] ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              row['spart'] ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              row['sorder'] ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              row['sm'] ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 3,
            child: _cellText(
              row['totalPenjualan'] ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              row['profit'] ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 2,
            child: _cellText(
              row['profitPercent'] ?? '-',
              Alignment.centerRight,
              isBold: true,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, Alignment alignment) {
    return Container(
      alignment: alignment,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _cellText(
    String value,
    Alignment alignment, {
    bool isBold = false,
    Color color = Colors.white,
  }) {
    return Container(
      alignment: alignment,
      child: Text(
        value,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryStrip(List<Map<String, dynamic>> rows) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16.0),
        itemBuilder: (context, index) {
          final row = rows[index];
          return Container(
            width: 180,
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1D3B),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFF2E3A57)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${row['week']} PERFORMANCE",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  row['profit'] ?? '-',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF38BDF8),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  row['profitPercent'] ?? '-',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF10B981),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF2E3A57)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: highlightColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
