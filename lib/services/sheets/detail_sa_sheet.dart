import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:operationcore2/services/export_theme.dart';
import 'package:operationcore2/services/sheets/sheet_helper.dart';

class DetailSaSheet {
  static void populate({
    required Sheet sheet,
    required String saName,
    required int daysInMonth,
    required Map<int, Map<String, dynamic>> saDailyData,
  }) {
    final numFormatter = NumberFormat("#,##0", "id_ID");

    // 1. Column Widths
    final List<double> widths = [
      8.0, // 1: Tgl Invoice
      8.0, // 2: UE
      15.0, // 3: L/C
      15.0, // 4: OIL
      15.0, // 5: S/PART
      15.0, // 6: S/O
      15.0, // 7: S/M
      18.0, // 8: JUMLAH
      15.0, // 9: OFFSET
      15.0, // 10: HPP OIL
      15.0, // 11: HPP S/PART
      15.0, // 12: HPP S/ORDER
      15.0, // 13: HPP S/MATERIAL
    ];
    SheetHelper.applyColumnWidths(sheet, widths);

    // 2. Title
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0),
    );
    SheetHelper.setCell(
      sheet,
      0,
      1,
      saName.toUpperCase(),
      StyleFactory.title(),
    );

    // 3. Headers Setup
    final headerStyle = StyleFactory.header(
      "#c2cedb", // Light blue/grey typical for basic headers
      fontColor: ExportTheme.colorBlack,
    );

    // Merging logic for rows 1 & 2 (indices 1 & 2 in 0-based world for rows)
    // Now columns are 1 to 13
    final List<int> singleColSpanRow = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
    ];

    for (int col in singleColSpanRow) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 2),
      );
    }

    // Populate Top level headers (Row 1)
    SheetHelper.setCell(sheet, 1, 1, "Tgl", headerStyle);
    SheetHelper.setCell(sheet, 1, 2, "UE", headerStyle);
    SheetHelper.setCell(sheet, 1, 3, "L/C", headerStyle);
    SheetHelper.setCell(sheet, 1, 4, "OIL", headerStyle);
    SheetHelper.setCell(sheet, 1, 5, "S/PART", headerStyle);
    SheetHelper.setCell(sheet, 1, 6, "S/O", headerStyle);
    SheetHelper.setCell(sheet, 1, 7, "S/M", headerStyle);
    SheetHelper.setCell(sheet, 1, 8, "JUMLAH", headerStyle);

    SheetHelper.setCell(sheet, 1, 9, "OFFSET", headerStyle);
    SheetHelper.setCell(sheet, 1, 10, "HPP OIL", headerStyle);
    SheetHelper.setCell(sheet, 1, 11, "HPP S/PART", headerStyle);
    SheetHelper.setCell(sheet, 1, 12, "HPP S/ORDER", headerStyle);
    SheetHelper.setCell(sheet, 1, 13, "HPP S/MATERIAL", headerStyle);

    // 4. Data Population
    // Variables for grand totals
    int gUe = 0;
    int gLc = 0, gOil = 0, gSPart = 0, gSo = 0, gSm = 0, gJumlah = 0;
    int gOffset = 0, gHppOil = 0, gHppSPart = 0, gHppSo = 0, gHppSm = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      int row = day + 2;

      // Tanggal
      SheetHelper.setCell(sheet, row, 1, day.toString(), StyleFactory.label());

      final data = saDailyData[day];
      if (data == null) {
        for (int col = 2; col <= 13; col++) {
          SheetHelper.setCell(sheet, row, col, "-", StyleFactory.data());
        }
        continue;
      }

      final int ue = data['unitEntry'] ?? 0;

      final penj = data['penjualan'] as Map<String, dynamic>? ?? {};
      final lc = penj['lc'] ?? 0;
      final oilP = penj['oil'] ?? 0;
      final spartP = penj['sPart'] ?? 0;
      final soP = penj['sOrder'] ?? 0;
      final smP = penj['sMaterial'] ?? 0;
      final jumlah = penj['total'] ?? 0;

      final hpp = data['hpp'] as Map<String, dynamic>? ?? {};
      final offset = hpp['offset'] ?? 0;
      final oilH = hpp['oil'] ?? 0;
      final spartH = hpp['sPart'] ?? 0;
      final soH = hpp['sOrder'] ?? 0;
      final smH = hpp['sMaterial'] ?? 0;

      // Accumulate
      gUe += ue;
      gLc += (lc is num) ? lc.toInt() : 0;
      gOil += (oilP is num) ? oilP.toInt() : 0;
      gSPart += (spartP is num) ? spartP.toInt() : 0;
      gSo += (soP is num) ? soP.toInt() : 0;
      gSm += (smP is num) ? smP.toInt() : 0;
      gJumlah += (jumlah is num) ? jumlah.toInt() : 0;
      gOffset += (offset is num) ? offset.toInt() : 0;
      gHppOil += (oilH is num) ? oilH.toInt() : 0;
      gHppSPart += (spartH is num) ? spartH.toInt() : 0;
      gHppSo += (soH is num) ? soH.toInt() : 0;
      gHppSm += (smH is num) ? smH.toInt() : 0;

      final style = StyleFactory.data();
      SheetHelper.setCell(sheet, row, 2, numFormatter.format(ue), style);
      SheetHelper.setCell(sheet, row, 3, numFormatter.format(lc), style);
      SheetHelper.setCell(sheet, row, 4, numFormatter.format(oilP), style);
      SheetHelper.setCell(sheet, row, 5, numFormatter.format(spartP), style);
      SheetHelper.setCell(sheet, row, 6, numFormatter.format(soP), style);
      SheetHelper.setCell(sheet, row, 7, numFormatter.format(smP), style);
      SheetHelper.setCell(sheet, row, 8, numFormatter.format(jumlah), style);
      SheetHelper.setCell(sheet, row, 9, numFormatter.format(offset), style);
      SheetHelper.setCell(sheet, row, 10, numFormatter.format(oilH), style);
      SheetHelper.setCell(sheet, row, 11, numFormatter.format(spartH), style);
      SheetHelper.setCell(sheet, row, 12, numFormatter.format(soH), style);
      SheetHelper.setCell(sheet, row, 13, numFormatter.format(smH), style);
    }

    // 5. Summary Row
    int summaryRow = daysInMonth + 3;
    final totalStyle = StyleFactory.header(
      "#c2cedb",
      fontColor: ExportTheme.colorBlack,
    );

    SheetHelper.setCell(sheet, summaryRow, 1, "TOTAL", totalStyle);
    SheetHelper.setCell(
      sheet,
      summaryRow,
      2,
      numFormatter.format(gUe),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      3,
      numFormatter.format(gLc),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      4,
      numFormatter.format(gOil),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      5,
      numFormatter.format(gSPart),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      6,
      numFormatter.format(gSo),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      7,
      numFormatter.format(gSm),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      8,
      numFormatter.format(gJumlah),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      9,
      numFormatter.format(gOffset),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      10,
      numFormatter.format(gHppOil),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      11,
      numFormatter.format(gHppSPart),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      12,
      numFormatter.format(gHppSo),
      totalStyle,
    );
    SheetHelper.setCell(
      sheet,
      summaryRow,
      13,
      numFormatter.format(gHppSm),
      totalStyle,
    );
  }
}
