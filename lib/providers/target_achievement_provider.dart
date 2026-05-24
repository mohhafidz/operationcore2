import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:operationcore2/model/target_achievement_model.dart';
import 'package:operationcore2/repository/target_achievement_repository.dart';
import 'package:operationcore2/providers/dashboard_provider.dart';

final targetAchievementRepositoryProvider =
    Provider<TargetAchievementRepository>((ref) {
      final firestore = ref.watch(firestoreProvider);
      return TargetAchievementRepository(firestore);
    });

final targetAchievementDataProvider = StreamProvider<Map<String, dynamic>>((
  ref,
) {
  final repository = ref.watch(targetAchievementRepositoryProvider);
  return repository.streamTargetAchievementData();
});

class SelectedSAFilterNotifier extends Notifier<String> {
  @override
  String build() {
    return 'Semua SA';
  }

  void setFilter(String value) {
    state = value;
  }
}

final selectedSAFilterProvider =
    NotifierProvider<SelectedSAFilterNotifier, String>(() {
      return SelectedSAFilterNotifier();
    });

final targetAchievementUIStateProvider =
    Provider<AsyncValue<TargetAchievementUIState>>((ref) {
      final asyncRawData = ref.watch(targetAchievementDataProvider);
      final selectedSA = ref.watch(selectedSAFilterProvider);

      return asyncRawData.when(
        data: (data) {
          final saList = (data['saList'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
          final target = data['target'] as Map<String, dynamic>?;
          final details = Map<String, dynamic>.from(data['details'] as Map);

          final saNames = saList.map((sa) => sa['name'] as String).toList();
          final currentSaFilters = ['Semua SA', ...saNames];

          // Resolve selected SA
          final activeSA = currentSaFilters.contains(selectedSA)
              ? selectedSA
              : 'Semua SA';

          final uiState = _processSAData(
            selectedSA: activeSA,
            saList: saList,
            target: target,
            details: details,
            currentSaFilters: currentSaFilters,
          );

          return AsyncValue.data(uiState);
        },
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    });

int _toInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

TargetAchievementUIState _processSAData({
  required String selectedSA,
  required List<Map<String, dynamic>> saList,
  required Map<String, dynamic>? target,
  required Map<String, dynamic> details,
  required List<String> currentSaFilters,
}) {
  final now = DateTime.now();
  final totalDays = now.day; // current day count

  final List<String> activeSaIds = [];
  if (selectedSA == 'Semua SA') {
    activeSaIds.addAll(saList.map((sa) => sa['id'] as String));
  } else {
    final match = saList.firstWhere(
      (sa) => sa['name'] == selectedSA,
      orElse: () => {'id': '', 'name': ''},
    );
    if (match['id']!.isNotEmpty) {
      activeSaIds.add(match['id']!);
    }
  }

  // Map to hold daily data for display in the table
  final List<Map<String, dynamic>> dailyRows = [];

  // Daily actual revenues for the chart
  final List<double> actualPoints = [];

  // Monthly totals
  int totalSiu = 0;
  int totalJasa = 0;
  int totalOil = 0;
  int totalPart = 0;
  int totalSo = 0;
  int totalSm = 0;
  int totalPenjualanGlobal = 0;
  int totalHppGlobal = 0;
  int totalsoil = 0;
  int totaloffset = 0;
  int totalspart = 0;
  int totalSorder = 0;
  int totalSmaterial = 0;

  // Safe fallback targets in case target is null or empty
  final int targetSiuVal = _toInt(target?['SIU'] ?? 100);
  final int targetSiupersa = _toInt(target?['targetSiupersa'] ?? 33);
  final int workingDays = _toInt(target?['working_days'] ?? 26) > 0
      ? _toInt(target?['working_days'] ?? 26)
      : 26;

  final int saTargetSiu = selectedSA == 'Semua SA'
      ? targetSiuVal
      : targetSiupersa;
  final double dailySiuTarget = saTargetSiu / workingDays;

  for (int d = 1; d <= now.day; d++) {
    final String dayStr = d.toString().padLeft(2, '0');
    final String monthStr = now.month.toString().padLeft(2, '0');
    final String dateKey = "${now.year}-$monthStr-$dayStr";
    final String displayDate =
        "$dayStr ${DateFormat('MMM').format(now)} ${now.year}";

    int daySiu = 0;
    int dayJasa = 0;
    int dayOil = 0;
    int dayPart = 0;
    int daySo = 0;
    int daySm = 0;
    int dayHpp = 0;
    int dayoffset = 0;
    int dayoil = 0;
    int dayspart = 0;
    int daysorder = 0;
    int daysmaterial = 0;

    bool hasDataForDay = false;

    for (var saId in activeSaIds) {
      final List<dynamic> saDetails = details[saId] ?? [];
      final dayEntry = saDetails.cast<Map<String, dynamic>?>().firstWhere(
        (entry) => entry?['date'] == dateKey,
        orElse: () => null,
      );

      if (dayEntry != null) {
        hasDataForDay = true;
        daySiu += _toInt(dayEntry['unitEntry']);

        final penjualan = dayEntry['penjualan'] as Map<String, dynamic>? ?? {};
        dayJasa += _toInt(penjualan['lc']);
        dayOil += _toInt(penjualan['oil']);
        dayPart += _toInt(penjualan['sPart']);
        daySo += _toInt(penjualan['sOrder']);
        daySm += _toInt(penjualan['sMaterial']);

        final hpp = dayEntry['hpp'] as Map<String, dynamic>? ?? {};
        dayoffset += _toInt(hpp['offset']);
        dayoil += _toInt(hpp['oil']);
        dayspart += _toInt(hpp['sPart']);
        daysorder += _toInt(hpp['sOrder']);
        daysmaterial += _toInt(hpp['sMaterial']);
        dayHpp +=
            _toInt(hpp['lc']) +
            _toInt(hpp['oil']) +
            _toInt(hpp['sPart']) +
            _toInt(hpp['sOrder']) +
            _toInt(hpp['sMaterial']);
      }
    }

    final int dayTotalPenjualan = dayJasa + dayOil + dayPart + daySo + daySm;
    final int dayProfit = dayTotalPenjualan - dayHpp;
    final double dayProfitPercent = dayTotalPenjualan > 0
        ? (dayProfit / dayTotalPenjualan) * 100
        : 0.0;

    // Update monthly totals
    totalSiu += daySiu;
    totalJasa += dayJasa;
    totalOil += dayOil;
    totalPart += dayPart;
    totalSo += daySo;
    totalSm += daySm;
    totalsoil += dayoil;
    totaloffset += dayoffset;
    totalspart += dayspart;
    totalSorder += daysorder;
    totalSmaterial += daysmaterial;
    totalPenjualanGlobal += dayTotalPenjualan;
    totalHppGlobal += dayHpp;

    // Daily total for the chart
    actualPoints.add(dayTotalPenjualan.toDouble());

    // Decide SIU State
    String siuState = 'normal';
    if (hasDataForDay) {
      if (daySiu >= dailySiuTarget) {
        siuState = 'green';
      } else if (daySiu < dailySiuTarget * 0.7) {
        siuState = 'red';
      }
    }

    // Decide Profit State
    String profitState = 'normal';
    if (hasDataForDay && dayTotalPenjualan > 0) {
      if (dayProfitPercent >= 35.0) {
        profitState = 'green';
      } else if (dayProfitPercent < 30.0) {
        profitState = 'red';
      }
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    dailyRows.add({
      'date': displayDate,
      'siu': hasDataForDay ? daySiu : '-',
      'jasa': hasDataForDay ? currencyFormatter.format(dayJasa) : '-',
      'oil': hasDataForDay ? currencyFormatter.format(dayOil) : '-',
      'part': hasDataForDay ? currencyFormatter.format(dayPart) : '-',
      'so': hasDataForDay ? currencyFormatter.format(daySo) : '-',
      'sm': hasDataForDay ? currencyFormatter.format(daySm) : '-',
      'offset': hasDataForDay ? currencyFormatter.format(dayoffset) : '-',
      'soil': hasDataForDay ? currencyFormatter.format(dayoil) : '-',
      'spart': hasDataForDay ? currencyFormatter.format(dayspart) : '-',
      'sorder': hasDataForDay ? currencyFormatter.format(daysorder) : '-',
      'smaterial': hasDataForDay ? currencyFormatter.format(daysmaterial) : '-',
      'totalPenjualan': hasDataForDay
          ? currencyFormatter.format(dayTotalPenjualan)
          : '-',
      'totalHpp': hasDataForDay ? currencyFormatter.format(dayHpp) : '-',
      'profit': hasDataForDay ? currencyFormatter.format(dayProfit) : '-',
      'profitPercent': hasDataForDay
          ? "${dayProfitPercent.toStringAsFixed(1)}%"
          : '-',
      'siuState': siuState,
      'profitState': profitState,
      'isToday': d == now.day,
    });
  }

  final int totalRevenueTarget = selectedSA == 'Semua SA'
      ? _toInt(target?['total'] ?? 0)
      : _toInt(target?['revenuepersa'] ?? 0);

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );
  final int totalProfitGlobal = totalPenjualanGlobal - totalHppGlobal;
  final double totalProfitPercentGlobal = totalPenjualanGlobal > 0
      ? (totalProfitGlobal / totalPenjualanGlobal) * 100
      : 0.0;

  final Map<String, dynamic> monthlyTotal = {
    'siu': totalSiu,
    'jasa': currencyFormatter.format(totalJasa),
    'oil': currencyFormatter.format(totalOil),
    'part': currencyFormatter.format(totalPart),
    'so': currencyFormatter.format(totalSo),
    'sm': currencyFormatter.format(totalSm),
    'offset': currencyFormatter.format(totaloffset),
    'soil': currencyFormatter.format(totalsoil),
    'spart': currencyFormatter.format(totalspart),
    'sorder': currencyFormatter.format(totalSorder),
    'smaterial': currencyFormatter.format(totalSmaterial),
    'totalPenjualan': currencyFormatter.format(totalPenjualanGlobal),
    'totalHpp': currencyFormatter.format(totalHppGlobal),
    'profit': currencyFormatter.format(totalProfitGlobal),
    'profitPercent': "${totalProfitPercentGlobal.toStringAsFixed(1)}%",
  };

  final String totalRevenueStr =
      "Rp ${currencyFormatter.format(totalPenjualanGlobal)}";

  final double performanceRatio = totalRevenueTarget > 0
      ? (totalPenjualanGlobal / totalRevenueTarget) * 100
      : 0.0;
  final String trendPercentage =
      "${performanceRatio >= 100 ? '↗+' : '↘'}${performanceRatio.toStringAsFixed(1)}%";

  return TargetAchievementUIState(
    availableFilters: currentSaFilters,
    activeFilter: selectedSA,
    totalRevenueStr: totalRevenueStr,
    trendPercentage: trendPercentage,
    chartPoints: actualPoints,
    targetPoints: const [],
    tableRows: dailyRows,
    monthlyTotal: monthlyTotal,
  );
}
