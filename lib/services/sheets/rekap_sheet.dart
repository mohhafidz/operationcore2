import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:operationcore2/model/alluser.dart';
import 'package:operationcore2/model/dashboardmodel.dart';
import 'package:operationcore2/model/databulansebelum.dart';
import 'package:operationcore2/model/datatahunsebelum.dart';
import 'package:operationcore2/services/export_theme.dart';
import 'package:operationcore2/services/sheets/sheet_helper.dart';
import 'package:operationcore2/utils/dashboard_calculations.dart';

class RekapSheet {
  static void populate({
    required Sheet sheet,
    required String monthName,
    required DashboardData data,
    required Databulansebelum prevMonth,
    required Datatahunsebelum prevYear,
    required int totalWorkingDays,
    required int workingDay,
    required int remainingWorkingDays,
    required List<alluser> mekanikUsers,
    required List<alluser> leaderUsers,
    required List<alluser> saUsers,
    required List<alluser> csUsers,
    required Map<String, Map<String, dynamic>> productivityData,
    required int mechanicTarget,
    required int leaderTarget,
  }) {
    final List<ColumnConfig> configs = ExportTheme.rekapColumns;

    // Calculations
    final siuRes = DashboardCalculations.calculateMetric(
      actual: data.siuActual,
      target: data.siuTarget,
      prevMonth: prevMonth.siu,
      prevYear: prevYear.siu,
      totalWorkingDays: totalWorkingDays,
      daysElapsed: workingDay,
      remainingWorkingDays: remainingWorkingDays,
    );
    final jasaRes = DashboardCalculations.calculateMetric(
      actual: data.jasaActual,
      target: data.jasaTarget,
      prevMonth: prevMonth.jasa,
      prevYear: prevYear.jasa,
      totalWorkingDays: totalWorkingDays,
      daysElapsed: workingDay,
      remainingWorkingDays: remainingWorkingDays,
    );
    final oilRes = DashboardCalculations.calculateMetric(
      actual: data.oilActual,
      target: data.oilTarget,
      prevMonth: prevMonth.oil,
      prevYear: prevYear.oil,
      totalWorkingDays: totalWorkingDays,
      daysElapsed: workingDay,
      remainingWorkingDays: remainingWorkingDays,
    );
    final partRes = DashboardCalculations.calculateMetric(
      actual: data.partActual,
      target: data.partTarget,
      prevMonth: prevMonth.part,
      prevYear: prevYear.part,
      totalWorkingDays: totalWorkingDays,
      daysElapsed: workingDay,
      remainingWorkingDays: remainingWorkingDays,
    );
    final soRes = DashboardCalculations.calculateMetric(
      actual: data.sorderActual,
      target: data.sorderTarget,
      prevMonth: prevMonth.so,
      prevYear: prevYear.so,
      totalWorkingDays: totalWorkingDays,
      daysElapsed: workingDay,
      remainingWorkingDays: remainingWorkingDays,
    );
    final smRes = DashboardCalculations.calculateMetric(
      actual: data.materialActual,
      target: data.materialTarget,
      prevMonth: prevMonth.sm,
      prevYear: prevYear.sm,
      totalWorkingDays: totalWorkingDays,
      daysElapsed: workingDay,
      remainingWorkingDays: remainingWorkingDays,
    );
    final totalRes = DashboardCalculations.calculateMetric(
      actual: data.totalActual,
      target: data.totalTarget,
      prevMonth: prevMonth.total,
      prevYear: prevYear.total,
      totalWorkingDays: totalWorkingDays,
      daysElapsed: workingDay,
      remainingWorkingDays: remainingWorkingDays,
    );
    final bookRes = DashboardCalculations.calculateMetric(
      actual: data.bookingActual,
      target: data.bookingTarget,
      prevMonth: prevMonth.booking,
      prevYear: prevYear.booking,
      totalWorkingDays: totalWorkingDays,
      daysElapsed: workingDay,
      remainingWorkingDays: remainingWorkingDays,
    );

    // Title & Columns
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
    );
    SheetHelper.setCell(
      sheet,
      0,
      1,
      "REKAP DASHBOARD - $monthName",
      StyleFactory.title(),
    );

    SheetHelper.applyColumnWidths(sheet, configs.map((c) => c.width).toList());
    sheet.setRowHeight(0, 25.0);
    sheet.setRowHeight(2, 22.0);

    // Headers
    for (int i = 0; i < configs.length; i++) {
      if (i == 0) {
        // Top left cell with workingDay
        SheetHelper.setCell(
          sheet,
          2,
          i + 1,
          totalWorkingDays.toString(),
          StyleFactory.header("#FFFF00", fontColor: ExportTheme.colorBlack),
        );
      } else {
        SheetHelper.setCell(
          sheet,
          2,
          i + 1,
          configs[i].label,
          StyleFactory.header(configs[i].color),
        );
      }
    }

    int row = 3;

    void writeRow(
      String label,
      List<num> values, {
      bool isPct = false,
      bool useColBg = false,
      String? bg,
      String? font,
      bool bold = false,
    }) {
      _writeRow(
        sheet,
        row++,
        label,
        values,
        configs: configs,
        isPercentage: isPct,
        useColBg: useColBg,
        rowBgColor: bg,
        rowFontColor: font,
        isBold: bold,
      );
    }

    // Data Rows Map

    writeRow(
      "TOTAL S/D HARI INI",
      [
        data.siuActual,
        data.jasaActual,
        data.oilActual,
        data.partActual,
        data.sorderActual,
        data.materialActual,
        data.totalActual,
        data.bookingActual,
      ],
      useColBg: true,
      font: "#000000",
      bold: false,
    );

    writeRow(
      "TARGET",
      [
        data.siuTarget,
        data.jasaTarget,
        data.oilTarget,
        data.partTarget,
        data.sorderTarget,
        data.materialTarget,
        data.totalTarget,
        data.bookingTarget,
      ],
      useColBg: true,
      font: "#000000",
      bold: true,
    );

    writeRow(
      "% (HARI INI VS TARGET)",
      [
        siuRes.achievementPercentage,
        jasaRes.achievementPercentage,
        oilRes.achievementPercentage,
        partRes.achievementPercentage,
        soRes.achievementPercentage,
        smRes.achievementPercentage,
        totalRes.achievementPercentage,
        bookRes.achievementPercentage,
      ],
      isPct: true,
      bg: "#C6E0B4",
      font: "#385723",
    );

    writeRow(
      "AVERAGE PER HARI",
      [
        siuRes.averagePerHari,
        jasaRes.averagePerHari,
        oilRes.averagePerHari,
        partRes.averagePerHari,
        soRes.averagePerHari,
        smRes.averagePerHari,
        totalRes.averagePerHari,
        bookRes.averagePerHari,
      ],
      bg: "#808080",
      font: "#FFFFFF",
      bold: true,
    );

    writeRow(
      "SISA TARGET KE 100%",
      [
        siuRes.sisaTargetValue,
        jasaRes.sisaTargetValue,
        oilRes.sisaTargetValue,
        partRes.sisaTargetValue,
        soRes.sisaTargetValue,
        smRes.sisaTargetValue,
        totalRes.sisaTargetValue,
        bookRes.sisaTargetValue,
      ],
      bg: "#00B0F0",
      font: "#000000",
      bold: true,
    );

    writeRow(
      "SISA TARGET /HARI",
      [
        siuRes.sisaTargetPerHari,
        jasaRes.sisaTargetPerHari,
        oilRes.sisaTargetPerHari,
        partRes.sisaTargetPerHari,
        soRes.sisaTargetPerHari,
        smRes.sisaTargetPerHari,
        totalRes.sisaTargetPerHari,
        bookRes.sisaTargetPerHari,
      ],
      bg: "#E4DFEC",
      font: "#7030A0",
      bold: true,
    );

    writeRow(
      "MAKS ACHV BASED ON AVERAGE",
      [
        siuRes.maksAchvValue,
        jasaRes.maksAchvValue,
        oilRes.maksAchvValue,
        jasaRes.maksAchvValue,
        soRes.maksAchvValue,
        smRes.maksAchvValue,
        totalRes.maksAchvValue,
        bookRes.maksAchvValue,
      ],
      bg: "#FFFFFF",
      font: "#7030A0",
      bold: true,
    );

    writeRow(
      "MAKS ACHV (%)",
      [
        siuRes.maksAchvPercentage,
        jasaRes.maksAchvPercentage,
        oilRes.maksAchvPercentage,
        partRes.maksAchvPercentage,
        soRes.maksAchvPercentage,
        smRes.maksAchvPercentage,
        totalRes.maksAchvPercentage,
        bookRes.maksAchvPercentage,
      ],
      isPct: true,
      bg: "#00B0F0",
      font: "#7030A0",
      bold: true,
    );

    writeRow(
      "TARGET HARIAN MINIMAL (BUDGET)",
      [
        siuRes.dailyBudget,
        jasaRes.dailyBudget,
        oilRes.dailyBudget,
        partRes.dailyBudget,
        soRes.dailyBudget,
        smRes.dailyBudget,
        totalRes.dailyBudget,
        bookRes.dailyBudget,
      ],
      bg: "#808080",
      font: "#FFFFFF",
      bold: true,
    );

    writeRow(
      "VS LAST MONTH",
      [
        prevMonth.siu,
        prevMonth.jasa,
        prevMonth.oil,
        prevMonth.part,
        prevMonth.so,
        prevMonth.sm,
        prevMonth.total,
        prevMonth.booking,
      ],
      bg: "#FFFFFF",
      font: "#000000",
      bold: true,
    );

    writeRow(
      "% (MONTH VARIATION)",
      [
        siuRes.growthMonth,
        jasaRes.growthMonth,
        oilRes.growthMonth,
        partRes.growthMonth,
        soRes.growthMonth,
        smRes.growthMonth,
        totalRes.growthMonth,
        bookRes.growthMonth,
      ],
      isPct: true,
      bg: "#FFC7CE",
      font: "#9C0006",
    );

    writeRow(
      "VS LAST YEAR",
      [
        prevYear.siu,
        prevYear.jasa,
        prevYear.oil,
        prevYear.part,
        prevYear.so,
        prevYear.sm,
        prevYear.total,
        prevYear.booking,
      ],
      bg: "#FFFFFF",
      font: "#000000",
      bold: true,
    );

    writeRow(
      "% (YEAR VARIATION)",
      [
        siuRes.growthYear,
        jasaRes.growthYear,
        oilRes.growthYear,
        partRes.growthYear,
        soRes.growthYear,
        smRes.growthYear,
        totalRes.growthYear,
        bookRes.growthYear,
      ],
      isPct: true,
      bg: "#FFC7CE",
      font: "#9C0006",
    );

    // Productivity Sections
    row += 1;
    SheetHelper.setCell(
      sheet,
      row,
      1,
      "Productivity",
      StyleFactory.base(
        bgColor: "#247a00",
        fontColor: ExportTheme.colorWhite,
        bold: true,
        fontFamily: "Calibri",
      ),
    );

    row += 2;
    final List<String> mechHeaders = [
      "MEKANIK",
      "UNIT ENTRY",
      "PRODUCTIVITY",
      "TARGET",
      "TOTAL JASA",
      "PROSENTASE",
    ];
    for (int i = 0; i < mechHeaders.length; i++) {
      SheetHelper.setCell(
        sheet,
        row,
        i + 1,
        mechHeaders[i],
        StyleFactory.header("FF824E00", fontFamily: "Calibri"),
      );
    }
    row++;

    final numFormatter = NumberFormat("#,##0", "id_ID");
    final decFormatter = NumberFormat("#,##0.00", "id_ID");

    void writeProductivityLoop(
      List<alluser> users,
      int t, {
      String label = "MEKANIK",
    }) {
      for (var user in users) {
        final d = productivityData[user.userId] ?? {};
        final ue = (d['unitentry'] ?? 0) as num;
        final tj = (d['totaljasa'] ?? 0) as num;
        final prod = workingDay == 0 ? 0.0 : ue / workingDay;
        final p = t == 0 ? 0.0 : (tj / t * 100);

        SheetHelper.setCell(sheet, row, 1, user.name, StyleFactory.label());
        SheetHelper.setCell(
          sheet,
          row,
          2,
          numFormatter.format(ue),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          3,
          decFormatter.format(prod),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          4,
          numFormatter.format(t),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          5,
          numFormatter.format(tj),
          StyleFactory.data(),
        );
        SheetHelper.setCell(
          sheet,
          row,
          6,
          "${decFormatter.format(p)}%",
          StyleFactory.data(),
        );
        row++;
      }
    }

    writeProductivityLoop(mekanikUsers, mechanicTarget);

    row += 2;
    final List<String> leaderHeaders = [
      "LEADER",
      "UNIT ENTRY",
      "PRODUCTIVITY",
      "TARGET",
      "TOTAL JASA",
      "PROSENTASE",
    ];
    for (int i = 0; i < leaderHeaders.length; i++) {
      SheetHelper.setCell(
        sheet,
        row,
        i + 1,
        leaderHeaders[i],
        StyleFactory.header("FF824E00", fontFamily: "Calibri"),
      );
    }
    row++;
    writeProductivityLoop(leaderUsers, leaderTarget, label: "LEADER");

    row += 2;
    final List<String> saHeaders = [
      "SERVICE ADVISOR",
      "UNIT ENTRY",
      "PRODUCTIVITY",
    ];
    for (int i = 0; i < saHeaders.length; i++) {
      SheetHelper.setCell(
        sheet,
        row,
        i + 1,
        saHeaders[i],
        StyleFactory.header("FF824E00", fontFamily: "Calibri"),
      );
    }
    row++;
    for (var user in saUsers) {
      final d = productivityData[user.userId] ?? {};
      final ue = (d['unitentry'] ?? 0) as num;
      final prod = workingDay == 0 ? 0.0 : ue / workingDay;
      SheetHelper.setCell(sheet, row, 1, user.name, StyleFactory.label());
      SheetHelper.setCell(
        sheet,
        row,
        2,
        numFormatter.format(ue),
        StyleFactory.data(),
      );
      SheetHelper.setCell(
        sheet,
        row,
        3,
        decFormatter.format(prod),
        StyleFactory.data(),
      );
      row++;
    }

    row += 2;
    final List<String> csHeaders = ["CS SERVICE", "UNIT ENTRY", "PRODUCTIVITY"];
    for (int i = 0; i < csHeaders.length; i++) {
      SheetHelper.setCell(
        sheet,
        row,
        i + 1,
        csHeaders[i],
        StyleFactory.header("FF824E00", fontFamily: "Calibri"),
      );
    }
    row++;
    for (var user in csUsers) {
      final d = productivityData[user.userId] ?? {};
      final ue = (d['unitentry'] ?? 0) as num;
      final prod = workingDay == 0 ? 0.0 : ue / workingDay;
      SheetHelper.setCell(sheet, row, 1, user.name, StyleFactory.label());
      SheetHelper.setCell(
        sheet,
        row,
        2,
        numFormatter.format(ue),
        StyleFactory.data(),
      );
      SheetHelper.setCell(
        sheet,
        row,
        3,
        decFormatter.format(prod),
        StyleFactory.data(),
      );
      row++;
    }
  }

  static void _writeRow(
    Sheet sheet,
    int row,
    String label,
    List<num> values, {
    required List<ColumnConfig> configs,
    bool isPercentage = false,
    bool useColBg = false,
    String? rowBgColor,
    String? rowFontColor,
    bool isBold = false,
  }) {
    final formatter = NumberFormat("#,##0", "id_ID");

    // Label Style
    CellStyle lStyle = StyleFactory.label(
      bgColor: (label == "TOTAL S/D HARI INI" || label == "TARGET")
          ? "#FFFFFF"
          : rowBgColor,
      fontColor: rowFontColor ?? ExportTheme.colorBlack,
      bold:
          isBold ||
          label == "TARGET" ||
          label == "TOTAL S/D HARI INI" ||
          label == "VS LAST MONTH" ||
          label == "VS LAST YEAR",
    );
    SheetHelper.setCell(sheet, row, 1, label, lStyle);

    for (int i = 0; i < values.length; i++) {
      final config = configs[i + 1];
      String fV = isPercentage
          ? "${formatter.format(values[i].round())}%"
          : formatter.format(values[i].round());

      // Use column color if specified, otherwise row color
      String finalBg = useColBg ? config.color : (rowBgColor ?? "#FFFFFF");

      CellStyle style = StyleFactory.base(
        bgColor: finalBg,
        fontColor: rowFontColor ?? ExportTheme.colorBlack,
        bold: isBold,
      );

      SheetHelper.setCell(sheet, row, i + 2, fV, style);
    }
  }
}
