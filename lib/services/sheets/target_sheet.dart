import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:operationcore2/services/export_theme.dart';
import 'package:operationcore2/services/sheets/sheet_helper.dart';

class TargetSheet {
  static void populate({
    required Sheet sheet,
    required String monthHeader, // e.g., "JAN"
    required Map<String, dynamic> qtyData,
    required Map<String, dynamic> revData,
    required Map<String, dynamic> hppData,
    required int totalWorkingDays,
  }) {
    final numFormatter = NumberFormat("#,##0", "id_ID");
    final pctFormatter = NumberFormat("0.00'%'", "id_ID");

    // 1. Column Widths
    sheet.setColumnWidth(0, 10.0); // Col A
    sheet.setColumnWidth(1, 35.0); // Col B
    sheet.setColumnWidth(2, 25.0); // Col C

    // 2. Styles
    final headerStyle = StyleFactory.header(
      "#c2cedb",
      fontColor: ExportTheme.colorBlack,
      fontSize: 14,
    );
    final labelStyle = StyleFactory.label(bold: true);
    final valueStyle = StyleFactory.data(
      bgColor: "#FFFF00",
      bold: true,
    ); // Yellow column
    final subLabelStyle = StyleFactory.label(bold: true);

    int row = 0;

    // Row 0: Header "JUMLAH HARI KERJA"
    // sheet.merge(
    //   CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
    //   CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
    // );
    SheetHelper.setCell(sheet, row, 1, "JUMLAH HARI KERJA", headerStyle);
    SheetHelper.setCell(
      sheet,
      row,
      2,
      totalWorkingDays.toString(),
      headerStyle,
    );
    row++;

    // Row 1: Subheaders
    SheetHelper.setCell(sheet, row, 1, "PENJUALAN", labelStyle);
    SheetHelper.setCell(sheet, row, 2, monthHeader, headerStyle);
    row++;

    // Helper to write row
    void writeVerticalRow(
      // String? colA,
      String label,
      dynamic value, {
      bool isSub = false,
      bool isTotal = false,
    }) {
      CellStyle lblStyle = isTotal
          ? StyleFactory.label(bold: true)
          : (isSub ? StyleFactory.label() : labelStyle);
      CellStyle valStyle = valueStyle;

      String displayValue = "-";
      if (value != null) {
        if (value is num) {
          displayValue = numFormatter.format(value.round());
        } else {
          displayValue = value.toString();
        }
      }

      // SheetHelper.setCell(sheet, row, 1, colA ?? "", lblStyle);
      SheetHelper.setCell(sheet, row, 1, label, lblStyle);
      SheetHelper.setCell(sheet, row, 2, displayValue, valStyle);
      row++;
    }

    // 3. Sections
    // SECTION 1: PENJUALAN (QUANTITY)
    writeVerticalRow(
      "Umum :",
      qtyData['Jasa Umum'],
    ); // Assuming 'Umum' is Jasa Umum in Qty
    writeVerticalRow("  -  Jasa", qtyData['Jasa Umum'], isSub: true);
    writeVerticalRow("  -  Spare Part", qtyData['Spare Part'], isSub: true);
    writeVerticalRow("  -  Olie", qtyData['Olie'], isSub: true);
    writeVerticalRow("Free Service :", qtyData['Free Service']);
    writeVerticalRow("Warranty / Claim", qtyData['Warranty / Claim']);
    writeVerticalRow("P D I", qtyData['PDI']);
    writeVerticalRow("Lain-2", qtyData['Lain-lain']);

    // Total Q
    num totalQ = (qtyData['Total Penjualan (Q)'] ?? 0);
    SheetHelper.setCell(
      sheet,
      row,
      1,
      "Total Penjualan (Q)",
      StyleFactory.base(hAlign: HorizontalAlign.Right, bold: true),
    );
    SheetHelper.setCell(sheet, row, 2, numFormatter.format(totalQ), valueStyle);
    row++;

    // SECTION 2: PENJUALAN (RP)
    writeVerticalRow("Jasa Bengkel", revData['Jasa Bengkel']);
    writeVerticalRow("Spare-part", revData['Spare Part']);
    writeVerticalRow("Olie", revData['Olie']);
    writeVerticalRow("Sales Order", revData['Sales Order']);
    writeVerticalRow("Sub Material", revData['Sub Material']);
    writeVerticalRow("Lain-2", revData['Lain-lain']);

    // Total RP
    num totalRev =
        (revData['Total Penjualan (RP)'] ??
        ((revData['Jasa Bengkel'] ?? 0) +
            (revData['Spare Part'] ?? 0) +
            (revData['Olie'] ?? 0) +
            (revData['Sales Order'] ?? 0) +
            (revData['Sub Material'] ?? 0)));
    SheetHelper.setCell(
      sheet,
      row,
      1,
      "Total Penjualan (RP)",
      StyleFactory.base(hAlign: HorizontalAlign.Right, bold: true),
    );
    SheetHelper.setCell(
      sheet,
      row,
      2,
      numFormatter.format(totalRev),
      valueStyle,
    );
    row++;

    // SECTION 3: HPP (RP)
    writeVerticalRow("Biaya Jasa Bengkel", hppData['Biaya Jasa Bengkel']);
    writeVerticalRow("Spare Part", hppData['Spare Part']);
    writeVerticalRow("Olie", hppData['Olie']);
    writeVerticalRow("Sales Order", hppData['Sales Order']);
    writeVerticalRow("Sub Material", hppData['Sub Material']);
    writeVerticalRow(
      "Biaya Bahan Bengkel",
      hppData['Biaya Bahan Bengkel'] ?? "-",
    );
    writeVerticalRow("Profit Share", hppData['Profit Share']);
    writeVerticalRow("Lain-2", hppData['Lain-lain']);

    // Total HPP
    num totalHpp =
        (hppData['Total HP Penjualan'] ??
        ((hppData['Spare Part'] ?? 0) +
            (hppData['Olie'] ?? 0) +
            (hppData['Sales Order'] ?? 0) +
            (hppData['Sub Material'] ?? 0) +
            (hppData['Lain-lain'] ?? 0)));
    SheetHelper.setCell(
      sheet,
      row,
      1,
      "Total HP Penjualan",
      StyleFactory.base(hAlign: HorizontalAlign.Right, bold: true),
    );
    SheetHelper.setCell(
      sheet,
      row,
      2,
      numFormatter.format(totalHpp),
      valueStyle,
    );
    row++;

    // SECTION 4: LABA
    double profitPct = hppData['Total Laba (Rugi) Kotor (RP)'];

    SheetHelper.setCell(
      sheet,
      row,
      1,
      "Total Laba (Rugi) Kotor (RP)",
      StyleFactory.base(hAlign: HorizontalAlign.Left, bold: true),
    );
    SheetHelper.setCell(
      sheet,
      row,
      2,
      pctFormatter.format(profitPct),
      valueStyle,
    );
  }
}
