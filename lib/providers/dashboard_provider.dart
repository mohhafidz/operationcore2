import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/model/dashboardmodel.dart';
import 'package:operationcore2/model/databulansebelum.dart';
import 'package:operationcore2/model/datatahunsebelum.dart';
import 'package:operationcore2/repository/dashboard_repository.dart';
import 'package:operationcore2/utils/date_helper.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return DashboardRepository(firestore);
});

/// ===============================
/// STREAM DATA DASHBOARD
/// ===============================
final dashboardProvider = StreamProvider<DashboardData>((ref) {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.streamDashboard();
});

/// ===============================
/// STREAM HOLIDAYS
/// ===============================
final holidaysProvider = StreamProvider<List<String>>((ref) {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.streamHolidays();
});

/// ===============================
/// HARI KERJA BERJALAN
/// ===============================
final workingDayProvider = Provider<int>((ref) {
  final holidaysAsync = ref.watch(holidaysProvider);

  return holidaysAsync.when(
    data: (holidays) {
      return getWorkingDayIndex(holidays: holidays);
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// ===============================
/// TOTAL HARI KERJA BULAN INI
/// ===============================
final totalWorkingDayProvider = Provider<int>((ref) {
  final holidaysAsync = ref.watch(holidaysProvider);

  return holidaysAsync.when(
    data: (holidays) {
      final now = DateTime.now();

      final holidayDates = holidays.map(parseDate).toList();

      return countWorkingDays(
        year: now.year,
        month: now.month,
        holidays: holidayDates,
      );
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// ===============================
/// SISA HARI KERJA
/// ===============================
final remainingWorkingDayProvider = Provider<int>((ref) {
  final total = ref.watch(totalWorkingDayProvider);
  final current = ref.watch(workingDayProvider);

  return sisaharikerja(jumlahharikerja: total, harikerja: current);
});

/// ===============================
/// ambil data sebelum
/// ===============================

final databulansebelumProvider = StreamProvider<Databulansebelum>((ref) {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.streamDataBulanSebelum();
});

final datatahunsebelumProvider = StreamProvider<Datatahunsebelum>((ref) {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.streamDataTahunSebelum();
});
