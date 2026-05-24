import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:operationcore2/model/target_achievement_model.dart';

class DailyTransactionsCard extends StatefulWidget {
  final TargetAchievementUIState saData;

  const DailyTransactionsCard({super.key, required this.saData});

  @override
  State<DailyTransactionsCard> createState() => _DailyTransactionsCardState();
}

class _DailyTransactionsCardState extends State<DailyTransactionsCard> {
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.saData.tableRows;
    final monthlyTotal = widget.saData.monthlyTotal;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
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
          Text(
            "Data Transaksi Harian",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20.0),

          // Scrollable Table for responsive large screens
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: 1900,
                child: Column(
                  children: [
                    // Header Row
                    _buildTableHeader(),
                    const Divider(color: Colors.white12, height: 1.0),

                    // Data Rows
                    SizedBox(
                      height: 450,
                      child: Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: rows
                                  .map((row) => _buildTableRow(row))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Divider(color: Colors.white24, height: 1.0),

                    // Total Summary Row
                    _buildTableSummaryRow(monthlyTotal),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: _headerCell("DATE", Alignment.centerLeft)),
          Expanded(flex: 1, child: _headerCell("SIU", Alignment.center)),
          Expanded(flex: 2, child: _headerCell("JASA", Alignment.centerRight)),
          Expanded(flex: 2, child: _headerCell("OIL", Alignment.centerRight)),
          Expanded(flex: 2, child: _headerCell("PART", Alignment.centerRight)),
          Expanded(flex: 2, child: _headerCell("SO", Alignment.centerRight)),
          Expanded(flex: 2, child: _headerCell("SM", Alignment.centerRight)),
          Expanded(
            flex: 3,
            child: _headerCell("TOTAL PENJUALAN", Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell("OFFSET", Alignment.centerRight),
          ),
          Expanded(flex: 2, child: _headerCell("S-OIL", Alignment.centerRight)),
          Expanded(
            flex: 2,
            child: _headerCell("S-PART", Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell("S-ORDER", Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell("S-MATERIAL", Alignment.centerRight),
          ),

          Expanded(
            flex: 3,
            child: _headerCell("TOTAL HPP", Alignment.centerRight),
          ),
          Expanded(
            flex: 3,
            child: _headerCell("PROFIT", Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell("PROFIT %", Alignment.centerRight),
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
          color: const Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> row) {
    final isProfitGreen = row['profitState'] == 'green';
    final isProfitRed = row['profitState'] == 'red';
    final isToday = row['isToday'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFF38BDF8).withOpacity(0.08) : null,
        border: const Border(
          bottom: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                row['date'] ?? '',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // SIU
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                (row['siu'] ?? '').toString(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Jasa, Oil, Part, SO, SM
          Expanded(
            flex: 2,
            child: _cellText(row['jasa'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['oil'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['part'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['so'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['sm'] ?? '', Alignment.centerRight),
          ),
          // Total Penjualan
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                row['totalPenjualan'] ?? '',
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Offset, SOil, SPart, SOrder, SMaterial
          Expanded(
            flex: 2,
            child: _cellText(row['offset'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['soil'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['spart'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['sorder'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _cellText(row['smaterial'] ?? '', Alignment.centerRight),
          ),

          // Total HPP
          Expanded(
            flex: 3,
            child: _cellText(row['totalHpp'] ?? '', Alignment.centerRight),
          ),
          // Profit
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                row['profit'] ?? '',
                style: GoogleFonts.inter(
                  color: isProfitGreen
                      ? const Color(0xFF10B981)
                      : isProfitRed
                      ? const Color(0xFFEF4444)
                      : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Profit %
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                row['profitPercent'] ?? '',
                style: GoogleFonts.inter(
                  color: isProfitGreen
                      ? const Color(0xFF10B981)
                      : isProfitRed
                      ? const Color(0xFFEF4444)
                      : Colors.white70,
                  fontSize: 13,
                  fontWeight: isProfitGreen || isProfitRed
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellText(String value, Alignment alignment) {
    return Container(
      alignment: alignment,
      child: Text(
        value,
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTableSummaryRow(Map<String, dynamic> total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(
                left: 4.0,
              ), // Beri sedikit padding agar tulisan tidak terlalu mepet kiri luar
              alignment: Alignment.centerLeft,
              child: Text(
                "MONTHLY TOTAL",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF38BDF8),
                  fontSize:
                      11, // Sedikit dikecilkan agar fit di flex 2 tanpa overflow
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                (total['siu'] ?? '').toString(),
                style: GoogleFonts.inter(
                  color: const Color(0xFF38BDF8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(total['jasa'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(total['oil'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(total['part'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(total['so'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(total['sm'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 3,
            child: _summaryCellText(
              total['totalPenjualan'] ?? '',
              Alignment.centerRight,
              highlight: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(
              total['offset'] ?? '',
              Alignment.centerRight,
            ),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(total['soil'] ?? '', Alignment.centerRight),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(
              total['spart'] ?? '',
              Alignment.centerRight,
            ),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(
              total['sorder'] ?? '',
              Alignment.centerRight,
            ),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(
              total['smaterial'] ?? '',
              Alignment.centerRight,
            ),
          ),

          Expanded(
            flex: 3,
            child: _summaryCellText(
              total['totalHpp'] ?? '',
              Alignment.centerRight,
            ),
          ),
          Expanded(
            flex: 3,
            child: _summaryCellText(
              total['profit'] ?? '',
              Alignment.centerRight,
              isGreen: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: _summaryCellText(
              total['profitPercent'] ?? '',
              Alignment.centerRight,
              isGreen: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCellText(
    String value,
    Alignment alignment, {
    bool highlight = false,
    bool isGreen = false,
  }) {
    return Container(
      alignment: alignment,
      child: Text(
        value,
        style: GoogleFonts.inter(
          color: highlight
              ? const Color(0xFF38BDF8)
              : isGreen
              ? const Color(0xFF10B981)
              : Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
