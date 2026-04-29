import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:operationcore2/model/alluser.dart';
import 'package:operationcore2/model/dashboardmodel.dart';
import 'package:operationcore2/model/databulansebelum.dart';
import 'package:operationcore2/model/datatahunsebelum.dart';
import 'package:operationcore2/services/sheets/rekap_sheet.dart';
import 'package:operationcore2/services/sheets/harian_sheet.dart';
import 'package:operationcore2/services/sheets/detail_sa_sheet.dart';
import 'package:operationcore2/services/sheets/target_sheet.dart';

class ExportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> exportRekapDashboard({
    required DashboardData dashboardData,
    required Databulansebelum dataBulanSebelum,
    required Datatahunsebelum dataTahunSebelum,
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
  }) async {
    final now = DateTime.now();
    final String docId = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final String monthName = DateFormat('MMMM yyyy').format(now);

    // 0. FETCH TARGET DATA FIRST
    num TargetSiu = 0;
    num targetBooking = 0;
    num targetPDI = 0;
    num targetLcP = 0;
    num targetOilP = 0;
    num targetSPartP = 0;
    num targetSOrderP = 0;
    num targetSMaterialP = 0;
    num targetTotalPenjualan = 0;

    num targetOilH = 0;
    num targetSPartH = 0;
    num targetSOrderH = 0;
    num targetSMaterialH = 0;
    num targetTotalHpp = 0;

    Map<String, dynamic> targetQty = {};
    Map<String, dynamic> targetRev = {};
    Map<String, dynamic> targetHppMap = {};

    try {
      final tDoc = await _firestore.collection('target').doc(docId).get();
      if (tDoc.exists) {
        targetBooking = tDoc.data()?['targetBooking'] ?? 0;
      }
    } catch (_) {}

    try {
      final tDocQuantity = await _firestore
          .collection('target')
          .doc(docId)
          .collection('detail')
          .doc('penjualan (unit)')
          .get();
      if (tDocQuantity.exists) {
        targetQty = tDocQuantity.data() ?? {};
        TargetSiu = targetQty['Total Penjualan (Q)'] ?? 0;
        targetPDI = targetQty['PDI'] ?? 0;
      }
    } catch (_) {}

    try {
      final tDocQ = await _firestore
          .collection('target')
          .doc(docId)
          .collection('detail')
          .doc('total penjualan (Rp)')
          .get();
      if (tDocQ.exists) {
        targetRev = tDocQ.data() ?? {};
        targetLcP = targetRev['Jasa Bengkel'] ?? 0;
        targetOilP = targetRev['Oil'] ?? 0;
        targetSPartP = targetRev['Spare Part'] ?? 0;
        targetSOrderP = targetRev['Sub Order'] ?? 0;
        targetSMaterialP = targetRev['Sub Material'] ?? 0;
      }
    } catch (_) {}

    // The user now only uses two detail documents.
    // HPP targets are not explicitly requested as a separate category anymore.
    // If needed, they could be retrieved from 'total penjualan (Rp)' as well.
    // For now, setting targetHppMap to targetRev to avoid breaking existing logic.
    targetHppMap = targetRev;
    targetOilH = targetHppMap['Oil'] ?? 0;
    targetSPartH = targetHppMap['Spare Part'] ?? 0;
    targetSOrderH = targetHppMap['Sub Order'] ?? 0;
    targetSMaterialH = targetHppMap['Sub Material'] ?? 0;

    targetTotalPenjualan =
        targetLcP +
        targetOilP +
        targetSPartP +
        targetSOrderP +
        targetSMaterialP;

    targetTotalHpp =
        targetOilH + targetSPartH + targetSOrderH + targetSMaterialH;

    // Fetch Data Harian
    final dailyData = await _fetchHarianData(docId, saUsers);

    var excel = Excel.createExcel();

    // 1. REKAP UTAMA SHEET
    excel.rename('Sheet1', 'Rekap Utama');
    Sheet sheetRekap = excel['Rekap Utama'];
    RekapSheet.populate(
      sheet: sheetRekap,
      monthName: monthName,
      data: dashboardData,
      prevMonth: dataBulanSebelum,
      prevYear: dataTahunSebelum,
      totalWorkingDays: totalWorkingDays,
      workingDay: workingDay,
      remainingWorkingDays: remainingWorkingDays,
      mekanikUsers: mekanikUsers,
      leaderUsers: leaderUsers,
      saUsers: saUsers,
      csUsers: csUsers,
      productivityData: productivityData,
      mechanicTarget: mechanicTarget,
      leaderTarget: leaderTarget,
    );

    // 1.5 TARGET SHEET
    // Sheet sheetTarget = excel['Target'];
    // TargetSheet.populate(
    //   sheet: sheetTarget,
    //   monthHeader: DateFormat('MMM').format(now).toUpperCase(),
    //   qtyData: targetQty,
    //   revData: targetRev,
    //   hppData: targetHppMap,
    //   totalWorkingDays: totalWorkingDays,
    // );

    // 2. HARIAN SHEET
    Sheet sheetHarian = excel['Harian'];
    HarianSheet.populate(
      sheet: sheetHarian,
      monthName: monthName,
      year: now.year,
      month: now.month,
      dailyData: dailyData,
      targetSiu: TargetSiu,
      targetBooking: targetBooking,
      targetPDI: targetPDI,
      targetLcP: targetLcP,
      targetOilP: targetOilP,
      targetSPartP: targetSPartP,
      targetSOrderP: targetSOrderP,
      targetSMaterialP: targetSMaterialP,
      targetTotalPenjualan: targetTotalPenjualan,
      targetOilH: targetOilH,
      targetSPartH: targetSPartH,
      targetSOrderH: targetSOrderH,
      targetSMaterialH: targetSMaterialH,
      targetTotalHpp: targetTotalHpp,
    );

    // 3. DETAIL SA SHEETS
    for (var sa in saUsers) {
      // Validate SA Name length, Excel sheet names can't exceed 31 chars
      String safeSaName = sa.name.length > 30
          ? sa.name.substring(0, 30)
          : sa.name;

      final detailSnapshot = await _firestore
          .collection('saperformance')
          .doc(docId)
          .collection('entries')
          .doc(sa.userId)
          .collection('detail')
          .get();

      final Map<int, Map<String, dynamic>> saDailyData = {};
      for (var doc in detailSnapshot.docs) {
        final dateId = doc.id; // YYYY-MM-DD
        final parts = dateId.split('-');
        if (parts.length >= 3) {
          final day = int.parse(parts.last);
          saDailyData[day] = doc.data();
        }
      }

      Sheet sheetSa = excel[safeSaName];
      DetailSaSheet.populate(
        sheet: sheetSa,
        saName: sa.name,
        daysInMonth: DateTime(now.year, now.month + 1, 0).day,
        saDailyData: saDailyData,
      );
    }

    // Since the default sheet is 'Sheet1' and we renamed it, we don't need to delete the default one,
    // but occasionally 'Sheet1' might be regenerated or we just ensure a clean slate:
    if (excel.tables.containsKey('Sheet1') && excel.tables.length > 1) {
      excel.delete('Sheet1');
    }

    String fileName = "Recap_Operation_$docId.xlsx";
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Rekap Excel',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (outputFile != null) {
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(outputFile)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }
    }
  }

  Future<Map<int, Map<String, dynamic>>> _fetchHarianData(
    String monthId,
    List<alluser> saUsers,
  ) async {
    final Map<int, Map<String, dynamic>> dailyMap = {};

    // 1. Fetch Service Tracking (Satu koleksi untuk semua hari)
    final stSnapshot = await _firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('serviceTracking')
        .get();

    for (var doc in stSnapshot.docs) {
      final dateId = doc.id; // YYYY-MM-DD
      final day = int.parse(dateId.split('-').last);
      final data = doc.data();

      dailyMap.putIfAbsent(day, () => _initialDailyData());
      dailyMap[day]!['booking'] = data['booking'] ?? 0;
      dailyMap[day]!['pdi'] = data['pdi'] ?? 0;
      dailyMap[day]!['msi'] = data['msiExpSvc'] ?? 0;
      dailyMap[day]!['sto'] = data['stoExpSvc'] ?? 0;
    }

    // 2. Fetch Detail SA untuk SIU, Penjualan, HPP
    for (var sa in saUsers) {
      final detailSnapshot = await _firestore
          .collection('saperformance')
          .doc(monthId)
          .collection('entries')
          .doc(sa.userId)
          .collection('detail')
          .get();

      for (var doc in detailSnapshot.docs) {
        final dateId = doc.id;
        final day = int.parse(dateId.split('-').last);
        final data = doc.data();

        dailyMap.putIfAbsent(day, () => _initialDailyData());

        // Sum SIU
        dailyMap[day]!['siu'] =
            (dailyMap[day]!['siu'] as int) + (data['unitEntry'] ?? 0) as int;

        // Sum Penjualan
        final p = data['penjualan'] as Map<String, dynamic>? ?? {};
        dailyMap[day]!['penjualan']['lc'] += p['lc'] ?? 0;
        dailyMap[day]!['penjualan']['oil'] += p['oil'] ?? 0;
        dailyMap[day]!['penjualan']['spart'] += p['sPart'] ?? 0;
        dailyMap[day]!['penjualan']['so'] += p['sOrder'] ?? 0;
        dailyMap[day]!['penjualan']['sm'] += p['sMaterial'] ?? 0;
        dailyMap[day]!['penjualan']['total'] += p['total'] ?? 0;

        // Sum HPP
        final h = data['hpp'] as Map<String, dynamic>? ?? {};
        dailyMap[day]!['hpp']['offset'] += h['offset'] ?? 0;
        dailyMap[day]!['hpp']['oil'] += h['oil'] ?? 0;
        dailyMap[day]!['hpp']['spart'] += h['sPart'] ?? 0;
        dailyMap[day]!['hpp']['so'] += h['sOrder'] ?? 0;
        dailyMap[day]!['hpp']['sm'] += h['sMaterial'] ?? 0;
        dailyMap[day]!['hpp']['total'] += h['total'] ?? 0;
      }
    }

    return dailyMap;
  }

  Map<String, dynamic> _initialDailyData() {
    return {
      'siu': 0,
      'booking': 0,
      'pdi': 0,
      'msi': 0,
      'sto': 0,
      'penjualan': {
        'lc': 0,
        'oil': 0,
        'spart': 0,
        'so': 0,
        'sm': 0,
        'total': 0,
      },
      'hpp': {'offset': 0, 'oil': 0, 'spart': 0, 'so': 0, 'sm': 0, 'total': 0},
    };
  }
}
