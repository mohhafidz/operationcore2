import 'package:excel/excel.dart';

// ========== THEME CONFIGURATION ==========
class ExportTheme {
  // Base Colors
  static const String colorSIU = "#FFFFFF";
  static const String colorOrange = "#FFC000"; // Jasa, SO, Booking
  static const String colorGrey = "#B4C6E7"; // Oil, Part, SM
  static const String colorTotal = "#F8CBAD";
  static const String colorMetricHeader = "#FFFFFF";
  static const String colorTargetLabel = "#007AAB";
  static const String colorWhite = "#FFFFFF";
  static const String colorBlack = "#000000";

  // Specialized Row/Cell Colors
  static const String colorBrown = "#543920";
  static const String colorGreen = "#004E1B";
  static const String colorGreyAverage = "#ACA7A7";
  static const String colorGreyLight = "#B0B0B0";
  static const String colorGreyBudget = "#9D9D9D";
  static const String colorPurpleText = "#C093C8";
  static const String colorHighlightBg = "#1E293B";

  // Harian Sheet Specific Colors
  static const String colorHarianSIU = "#FF0000";
  static const String colorHarianBooking = "#FFC000";
  static const String colorHarianPenjualan = "#00B0F0";
  static const String colorHarianHPP = "#FFFF00";
  static const String colorHarianTotal = "#92D050";
  static const String colorHarianProfit = "#00B0F0";
  static const String colorHarianHariKerja = "#00B050";

  static const String colorHarianProfitPersen = "#ffd965";
  static const String colorYellow = "#ffff00";

  // Column definitions for Rekap Utama
  static List<ColumnConfig> get rekapColumns => [
    ColumnConfig(label: "METRIC", color: colorMetricHeader, width: 50.0),
    ColumnConfig(label: "SIU", color: colorSIU),
    ColumnConfig(label: "JASA", color: colorOrange),
    ColumnConfig(label: "OIL", color: colorGrey),
    ColumnConfig(label: "PART", color: colorGrey),
    ColumnConfig(label: "S/ORDER (SO)", color: colorOrange),
    ColumnConfig(label: "S/MATERIAL (SM)", color: colorGrey),
    ColumnConfig(label: "TOTAL", color: colorTotal),
    ColumnConfig(label: "BOOKING", color: colorOrange),
  ];
}

class ColumnConfig {
  final String label;
  final String color;
  final double width;
  ColumnConfig({required this.label, required this.color, this.width = 22.0});
}

class StyleFactory {
  static CellStyle base({
    String? bgColor,
    String? fontColor,
    bool bold = false,
    int? fontSize = 14,
    HorizontalAlign hAlign = HorizontalAlign.Center,
    bool hasBorder = true,
    String? fontFamily,
  }) {
    return CellStyle(
      backgroundColorHex: ExcelColor.fromHexString(bgColor ?? "#FFFFFF"),
      fontColorHex: ExcelColor.fromHexString(
        fontColor ?? ExportTheme.colorBlack,
      ),
      bold: bold,
      fontSize: fontSize,
      fontFamily: fontFamily ?? "Arial",
      horizontalAlign: hAlign,
      verticalAlign: VerticalAlign.Center,
      leftBorder: hasBorder
          ? Border(borderStyle: BorderStyle.Medium)
          : Border(borderStyle: BorderStyle.None),
      rightBorder: hasBorder
          ? Border(borderStyle: BorderStyle.Medium)
          : Border(borderStyle: BorderStyle.None),
      topBorder: hasBorder
          ? Border(borderStyle: BorderStyle.Medium)
          : Border(borderStyle: BorderStyle.None),
      bottomBorder: hasBorder
          ? Border(borderStyle: BorderStyle.Medium)
          : Border(borderStyle: BorderStyle.None),
    );
  }

  static CellStyle header(
    String bgColor, {
    int? fontSize,
    String? fontFamily,
    String? fontColor,
  }) => base(
    bgColor: bgColor,
    bold: true,
    fontSize: fontSize ?? 14,
    fontFamily: fontFamily,
    fontColor: fontColor,
  );

  static CellStyle title() => base(
    bold: true,
    fontSize: 14,
    hasBorder: false,
    bgColor: ExportTheme.colorWhite,
  );

  static CellStyle label({
    String? bgColor,
    String? fontColor,
    bool bold = false,
  }) => base(
    bgColor: bgColor,
    fontColor: fontColor,
    bold: bold,
    hAlign: HorizontalAlign.Left,
  );

  static CellStyle data({
    String? bgColor,
    String? fontColor,
    bool bold = false,
  }) => base(bgColor: bgColor, fontColor: fontColor, bold: bold);

  static CellStyle highlight({String? bgColor, String? fontColor}) =>
      base(bgColor: bgColor, fontColor: fontColor, bold: false);
}
