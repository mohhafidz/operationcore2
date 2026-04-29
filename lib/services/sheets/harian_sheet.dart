import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:operationcore2/services/export_theme.dart';
import 'package:operationcore2/services/sheets/sheet_helper.dart';

class HarianSheet {
  static void populate({
    required Sheet sheet,
    required String monthName,
    required int year,
    required int month,
    required Map<int, Map<String, dynamic>> dailyData,
    required num targetSiu,
    required num targetBooking,
    required num targetPDI,
    required num targetLcP,
    required num targetOilP,
    required num targetSPartP,
    required num targetSOrderP,
    required num targetSMaterialP,
    required num targetTotalPenjualan,
    required num targetOilH,
    required num targetSPartH,
    required num targetSOrderH,
    required num targetSMaterialH,
    required num targetTotalHpp,
  }) {
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final numFormatter = NumberFormat("#,##0", "id_ID");

    // 1. Column Widths
    final List<double> widths = [
      8.0,  // TGL
      10.0, // SIU
      12.0, // BOOKING
      8.0,  // PDI
      15.0, // BOOKING RATE
      15.0, // L/C
      15.0, // OIL
      18.0, // S/PART
      18.0, // S/ORDER
      18.0, // S/MATERIAL
      18.0, // TOTAL PENJUALAN
      18.0, // OFFSET
      22.0, // OIL
      18.0, // S/PART
      18.0, // S/ORDER
      18.0, // S/MATERIAL
      18.0, // TOTAL HPP
      18.0, // PROFIT
      22.0, // PROFIT (%)
      20.0, // HARI KERJA
    ];
    SheetHelper.applyColumnWidths(sheet, widths);

    // 2. Title
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
    );
    SheetHelper.setCell(
      sheet,
      0,
      1,
      "LAPORAN HARIAN - $monthName",
      StyleFactory.title(),
    );

    // 3. Merged Headers (Row 2)
    // PENJUALAN: L/C to TOTAL PENJUALAN -> cols 6 to 11 (1-indexed) -> cols 5 to 10 (0-indexed)
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 2),
      CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 2),
    );
    SheetHelper.setCell(
      sheet,
      2,
      5,
      "PENJUALAN",
      StyleFactory.header(ExportTheme.colorHarianPenjualan),
    );
    // HPP: OFFSET to TOTAL HPP -> cols 12 to 17 (1-indexed) -> cols 11 to 16 (0-indexed)
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 2),
      CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: 2),
    );
    SheetHelper.setCell(
      sheet,
      2,
      11,
      "HPP",
      StyleFactory.header(
        ExportTheme.colorHarianHPP,
        fontColor: ExportTheme.colorBlack,
      ),
    );

    // 4. Main Headers (Row 3)
    final Map<int, String> headers = {
      1: "TGL",
      2: "SIU",
      3: "BOOKING",
      4: "PDI",
      5: "BOOKING RATE",
      6: "L/C",
      7: "OIL",
      8: "S/PART",
      9: "S/ORDER",
      10: "S/MATERIAL",
      11: "TOTAL PENJUALAN",
      12: "OFFSET",
      13: "OIL",
      14: "S/PART",
      15: "S/ORDER",
      16: "S/MATERIAL",
      17: "TOTAL HPP",
      18: "PROFIT",
      19: "PROFIT (%)",
      20: "HARI KERJA",
    };

    final Map<int, String> headerColors = {
      1: ExportTheme.colorWhite,
      2: ExportTheme.colorHarianSIU,
      3: ExportTheme.colorHarianSIU,
      4: ExportTheme.colorHarianSIU,
      5: ExportTheme.colorHarianSIU,
      6: ExportTheme.colorHarianPenjualan,
      7: ExportTheme.colorHarianPenjualan,
      8: ExportTheme.colorHarianPenjualan,
      9: ExportTheme.colorHarianPenjualan,
      10: ExportTheme.colorHarianPenjualan,
      11: ExportTheme.colorHarianTotal,
      12: ExportTheme.colorHarianHPP,
      13: ExportTheme.colorHarianHPP,
      14: ExportTheme.colorHarianHPP,
      15: ExportTheme.colorHarianHPP,
      16: ExportTheme.colorHarianHPP,
      17: ExportTheme.colorHarianTotal,
      18: ExportTheme.colorHarianProfit,
      19: ExportTheme.colorHarianTotal,
      20: ExportTheme.colorHarianHariKerja,
    };

    headers.forEach((col, label) {
      final color = headerColors[col] ?? ExportTheme.colorWhite;
      final fColor =
          (color == ExportTheme.colorHarianHPP ||
              color == ExportTheme.colorWhite)
          ? ExportTheme.colorBlack
          : ExportTheme.colorWhite;
      SheetHelper.setCell(
        sheet,
        3,
        col,
        label,
        StyleFactory.header(color, fontColor: fColor),
      );
    });

    // Totals for summary
    double grandSIU = 0, grandBooking = 0, grandPDI = 0;
    double grandLC = 0,
        grandOilP = 0,
        grandSPartP = 0,
        grandSOrderP = 0,
        grandSMaterialP = 0,
        grandTotalPenjualan = 0;
    double grandOffsetH = 0,
        grandOilH = 0,
        grandSPartH = 0,
        grandSOrderH = 0,
        grandSMaterialH = 0,
        grandTotalHPP = 0;

    // 5. Data Rows
    int activeDays = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      int row = day + 3;
      final data = dailyData[day];

      SheetHelper.setCell(sheet, row, 1, day.toString(), StyleFactory.label());

      if (data != null) {
        activeDays++;
        final siu = (data['siu'] ?? 0) as num;
        final booking = (data['booking'] ?? 0) as num;
        final pdi = (data['pdi'] ?? 0) as num;

        final bookingRate = (booking / (siu - pdi) * 100);

        final penj = data['penjualan'] as Map<String, dynamic>? ?? {};
        final lc = (penj['lc'] ?? 0) as num;
        final oilP = (penj['oil'] ?? 0) as num;
        final spartP = (penj['spart'] ?? 0) as num;
        final sorderP = (penj['so'] ?? 0) as num;
        final smaterialP = (penj['sm'] ?? 0) as num;
        final totalP = (penj['total'] ?? 0) as num;

        final hpp = data['hpp'] as Map<String, dynamic>? ?? {};
        final offsetH = (hpp['offset'] ?? 0) as num;
        final oilH = (hpp['oil'] ?? 0) as num;
        final spartH = (hpp['spart'] ?? 0) as num;
        final sorderH = (hpp['so'] ?? 0) as num;
        final smaterialH = (hpp['sm'] ?? 0) as num;
        final totalH = (hpp['total'] ?? 0) as num;

        final profit = totalP - totalH;
        final profitPct = totalP == 0 ? 0.0 : (profit / totalP * 100);

        final bgyellow = StyleFactory.header(ExportTheme.colorYellow);

        // Populate Cells
        SheetHelper.setCell(
          sheet,
          row,
          2,
          numFormatter.format(siu),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          3,
          numFormatter.format(booking),
          bgyellow,
        );
        SheetHelper.setCell(sheet, row, 4, numFormatter.format(pdi), bgyellow);
        SheetHelper.setCell(
          sheet,
          row,
          5,
          "${bookingRate.round()}%",
          StyleFactory.data(),
        );

        SheetHelper.setCell(
          sheet,
          row,
          6,
          numFormatter.format(lc),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          7,
          numFormatter.format(oilP),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          8,
          numFormatter.format(spartP),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          9,
          numFormatter.format(sorderP),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          10,
          numFormatter.format(smaterialP),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          11,
          numFormatter.format(totalP),
          StyleFactory.data(bgColor: ExportTheme.colorHarianTotal),
        );

        SheetHelper.setCell(
          sheet,
          row,
          12,
          numFormatter.format(offsetH),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          13,
          numFormatter.format(oilH),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          14,
          numFormatter.format(spartH),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          15,
          numFormatter.format(sorderH),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          16,
          numFormatter.format(smaterialH),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          17,
          numFormatter.format(totalH),
          StyleFactory.data(bgColor: ExportTheme.colorHarianTotal),
        );

        SheetHelper.setCell(
          sheet,
          row,
          18,
          numFormatter.format(profit),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          19,
          "${profitPct.toStringAsFixed(2)}%",
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          20,
          activeDays.toString(),
          StyleFactory.data(
            bgColor: ExportTheme.colorHarianHariKerja,
            fontColor: ExportTheme.colorWhite,
          ),
        );

        // Accumulate
        grandSIU += siu;
        grandBooking += booking;
        grandPDI += pdi;
        grandLC += lc;
        grandOilP += oilP;
        grandSPartP += spartP;
        grandSOrderP += sorderP;
        grandSMaterialP += smaterialP;
        grandTotalPenjualan += totalP;
        grandOffsetH += offsetH;
        grandOilH += oilH;
        grandSPartH += spartH;
        grandSOrderH += sorderH;
        grandSMaterialH += smaterialH;
        grandTotalHPP += totalH;
      } else {
        for (int col = 2; col <= 20; col++)
          SheetHelper.setCell(sheet, row, col, "-", StyleFactory.data());
      }
    }

    // 6. Summary Row (TOTAL)
    int summaryRow = daysInMonth + 4;
    final totalStyle = StyleFactory.header(
      ExportTheme.colorHarianTotal,
      fontColor: ExportTheme.colorBlack,
    );

    final totalValueStyle = StyleFactory.header(
      ExportTheme.colorHarianProfitPersen,
    );

    SheetHelper.setCell(sheet, summaryRow, 1, "TOTAL", totalStyle);
    SheetHelper.setCell(
      sheet,
      summaryRow,
      2,
      numFormatter.format(grandSIU),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      3,
      numFormatter.format(grandBooking),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      4,
      numFormatter.format(grandPDI),
      totalValueStyle,
    );

    double grandBookingRate = (grandBooking / (grandSIU - grandPDI) * 100);
    SheetHelper.setCell(
      sheet,
      summaryRow,
      5,
      "${grandBookingRate.toStringAsFixed(2)}%",
      totalValueStyle,
    );

    SheetHelper.setCell(
      sheet,
      summaryRow,
      6,
      numFormatter.format(grandLC),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      7,
      numFormatter.format(grandOilP),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      8,
      numFormatter.format(grandSPartP),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      9,
      numFormatter.format(grandSOrderP),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      10,
      numFormatter.format(grandSMaterialP),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      11,
      numFormatter.format(grandTotalPenjualan),
      totalStyle,
    );

    SheetHelper.setCell(
      sheet,
      summaryRow,
      12,
      '',
      StyleFactory.header(ExportTheme.colorBlack),
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      13,
      numFormatter.format(grandOilH),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      14,
      numFormatter.format(grandSPartH),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      15,
      numFormatter.format(grandSOrderH),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      16,
      numFormatter.format(grandSMaterialH),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      17,
      numFormatter.format(grandTotalHPP),
      totalStyle,
    );

    double grandProfit = grandTotalPenjualan - grandTotalHPP;
    double grandProfitPct = grandTotalPenjualan == 0
        ? 0.0
        : (grandProfit / grandTotalPenjualan * 100);
    SheetHelper.setCell(
      sheet,
      summaryRow,
      18,
      numFormatter.format(grandProfit),
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      19,
      "${grandProfitPct.toStringAsFixed(2)}%",
      totalValueStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      20,
      activeDays.toString(),
      totalStyle,
    );

    // 7. Summary Row (TARGET)
    int targetRow = summaryRow + 1;
    final targetLabelStyle = StyleFactory.header(
      ExportTheme.colorGreyLight,
      fontColor: ExportTheme.colorBlack,
    );
    final targetDataStyle = StyleFactory.data();

    num profit = targetTotalPenjualan - targetTotalHpp;
    double profitpercentage = targetTotalPenjualan == 0
        ? 0.0
        : (profit / targetTotalPenjualan * 100);

    SheetHelper.setCell(sheet, targetRow, 1, "TARGET", targetLabelStyle);
    for (int col = 2; col <= 20; col++) {
      if (col == 2) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetSiu),
          targetDataStyle,
        );
      } else if (col == 3) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetBooking),
          targetDataStyle,
        );
      } else if (col == 4) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetPDI),
          targetDataStyle,
        );
      } else if (col == 5) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          "-",
          StyleFactory.data(bgColor: ExportTheme.colorBlack),
        );
      } else if (col == 6) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetLcP),
          targetDataStyle,
        );
      } else if (col == 7) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetOilP),
          targetDataStyle,
        );
      } else if (col == 8) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetSPartP),
          targetDataStyle,
        );
      } else if (col == 9) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetSOrderP),
          targetDataStyle,
        );
      } else if (col == 10) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetSMaterialP),
          targetDataStyle,
        );
      } else if (col == 11) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetTotalPenjualan),
          targetDataStyle,
        );
      } else if (col == 12) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          "-",
          StyleFactory.data(bgColor: ExportTheme.colorBlack),
        );
      } else if (col == 13) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetOilH),
          targetDataStyle,
        );
      } else if (col == 14) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetSPartH),
          targetDataStyle,
        );
      } else if (col == 15) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetSOrderH),
          targetDataStyle,
        );
      } else if (col == 16) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetSMaterialH),
          targetDataStyle,
        );
      } else if (col == 17) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(targetTotalHpp),
          targetDataStyle,
        );
      } else if (col == 18) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          numFormatter.format(profit),
          targetDataStyle,
        );
      } else if (col == 19) {
        SheetHelper.setCell(
          sheet,
          targetRow,
          col,
          "${profitpercentage.toStringAsFixed(2)}%",
          targetDataStyle,
        );
      } else {
        SheetHelper.setCell(sheet, targetRow, col, "-", targetDataStyle);
      }
    }

    // 8. Summary Row (ACH %)
    int achRow = targetRow + 1;
    String getAch(num actual, num target) {
      if (target == 0) return "0.00%";
      return "${((actual / target) * 100).toStringAsFixed(2)}%";
    }

    SheetHelper.setCell(sheet, achRow, 1, "ACH (%)", totalStyle);
    for (int col = 2; col <= 20; col++) {
      if (col == 2) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandSIU, targetSiu),
          totalStyle,
        );
      } else if (col == 3) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandBooking, targetBooking),
          totalStyle,
        );
      } else if (col == 4) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandPDI, targetPDI),
          totalStyle,
        );
      } else if (col == 5) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          "-",
          StyleFactory.data(bgColor: ExportTheme.colorBlack),
        );
      } else if (col == 6) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandLC, targetLcP),
          totalStyle,
        );
      } else if (col == 7) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandOilP, targetOilP),
          totalStyle,
        );
      } else if (col == 8) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandSPartP, targetSPartP),
          totalStyle,
        );
      } else if (col == 9) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandSOrderP, targetSOrderP),
          totalStyle,
        );
      } else if (col == 10) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandSMaterialP, targetSMaterialP),
          totalStyle,
        );
      } else if (col == 11) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandTotalPenjualan, targetTotalPenjualan),
          totalStyle,
        );
      } else if (col == 12) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          "-",
          StyleFactory.data(bgColor: ExportTheme.colorBlack),
        );
      } else if (col == 13) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandOilH, targetOilH),
          totalStyle,
        );
      } else if (col == 14) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandSPartH, targetSPartH),
          totalStyle,
        );
      } else if (col == 15) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandSOrderH, targetSOrderH),
          totalStyle,
        );
      } else if (col == 16) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandSMaterialH, targetSMaterialH),
          totalStyle,
        );
      } else if (col == 17) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandTotalHPP, targetTotalHpp),
          totalStyle,
        );
      } else if (col == 18) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandProfit, profit),
          totalStyle,
        );
      } else if (col == 19) {
        SheetHelper.setCell(
          sheet,
          achRow,
          col,
          getAch(grandProfitPct, profitpercentage),
          totalStyle,
        );
      } else {
        SheetHelper.setCell(sheet, achRow, col, "-", totalStyle);
      }
    }
  }
}
