import 'package:excel/excel.dart';

class SheetHelper {
  static void setCell(Sheet sheet, int row, int col, String value, CellStyle style) {
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.value = TextCellValue(value);
    cell.cellStyle = style;
  }

  static void applyColumnWidths(Sheet sheet, List<double> widths) {
    sheet.setColumnWidth(0, 2.0); // Margin
    for (int i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i + 1, widths[i]);
    }
  }
}
