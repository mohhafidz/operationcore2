import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// ======================================================
/// FIRESTORE PROVIDER
/// ======================================================

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// ======================================================
/// REPOSITORY PROVIDER
/// ======================================================

final saPerformanceRepositoryProvider = Provider<SaPerformanceRepository>((
  ref,
) {
  return SaPerformanceRepository(ref.read(firestoreProvider));
});

/// ======================================================
/// LOAD SERVICE TRACKING TODAY
/// ======================================================

final serviceTrackingTodayProvider = FutureProvider<Map<String, int>?>((
  ref,
) async {
  final repo = ref.read(saPerformanceRepositoryProvider);
  return repo.getTodayServiceTracking();
});

/// ======================================================
/// LOAD TODAY SA DETAIL (per user)
/// ======================================================

final todaySaDetailProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, saId) async {
      final repo = ref.read(saPerformanceRepositoryProvider);
      return repo.getTodaySaDetail(saId);
    });

/// ======================================================
/// SAVE SA PERFORMANCE
/// ======================================================

final saPerformanceSaveProvider =
    StateNotifierProvider<SaPerformanceSaveNotifier, AsyncValue<void>>((ref) {
      return SaPerformanceSaveNotifier(
        ref.read(saPerformanceRepositoryProvider),
      );
    });

/// ======================================================
/// REPOSITORY
/// ======================================================

class SaPerformanceRepository {
  final FirebaseFirestore firestore;

  SaPerformanceRepository(this.firestore);

  String _getMonthId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  String _getDateId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// ======================================================
  /// SAVE SA PERFORMANCE (entries)
  /// ======================================================

  Map<String, dynamic> buildIncrementMap(String prefix, Map<String, int> data) {
    final result = <String, dynamic>{};

    data.forEach((key, value) {
      result['$prefix.$key'] = FieldValue.increment(value);
    });

    return result;
  }

  Future<void> saveSaPerformance({
    required String saId,
    required String saName,
    required int unitEntry,
    required Map<String, int> penjualan,
    required Map<String, int> hpp,
    Map<String, dynamic>? oldData,
  }) async {
    final monthId = _getMonthId();
    final dateId = _getDateId();

    final saRef = firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('entries')
        .doc(saId);

    final detailRef = saRef.collection('detail').doc(dateId);

    // Calculate deltas for increments
    int unitEntryDelta = unitEntry;
    Map<String, int> penjualanDelta = Map.from(penjualan);
    Map<String, int> hppDelta = Map.from(hpp);

    if (oldData != null) {
      unitEntryDelta = unitEntry - ((oldData['unitEntry'] ?? 0) as num).toInt();

      final oldPenjualan = oldData['penjualan'] as Map<String, dynamic>? ?? {};
      penjualan.forEach((key, value) {
        penjualanDelta[key] = value - ((oldPenjualan[key] ?? 0) as num).toInt();
      });

      final oldHpp = oldData['hpp'] as Map<String, dynamic>? ?? {};
      hpp.forEach((key, value) {
        hppDelta[key] = value - ((oldHpp[key] ?? 0) as num).toInt();
      });
    }

    /// =========================
    /// 1. SAVE DETAIL (ABSOLUTE)
    /// =========================
    await detailRef.set({
      'date': dateId,
      'unitEntry': unitEntry,
      'penjualan': penjualan,
      'hpp': hpp,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    /// =========================
    /// 2. UPDATE AGGREGATE (INCREMENT BY DELTA)
    /// =========================
    final penjualanIncrement = buildIncrementMap('penjualan', penjualanDelta);
    final hppIncrement = buildIncrementMap('hpp', hppDelta);

    await saRef.set({
      'saId': saId,
      'saName': saName,
      'unitEntry': FieldValue.increment(unitEntryDelta),
      ...penjualanIncrement,
      ...hppIncrement,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    /// =========================
    /// 3. SYNC TO PRODUCTIVITY COLLECTION
    /// =========================
    final productivityRef = firestore
        .collection('productivity')
        .doc(monthId)
        .collection('detail')
        .doc(saId);

    await productivityRef.set({
      'unitentry': FieldValue.increment(unitEntryDelta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ======================================================
  /// SAVE SERVICE TRACKING (1 PER HARI)
  /// ======================================================

  Future<void> saveServiceTracking({
    required Map<String, int> serviceTracking,
    required String saName,
  }) async {
    final monthId = _getMonthId();
    final dateId = _getDateId();

    final docRef = firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('serviceTracking')
        .doc(dateId);

    final total =
        (serviceTracking['booking'] ?? 0) + (serviceTracking['pdi'] ?? 0);
    // (serviceTracking['msiExpSvc'] ?? 0) +
    // (serviceTracking['stoExpSvc'] ?? 0);

    await docRef.set({
      'booking': serviceTracking['booking'] ?? 0,
      'pdi': serviceTracking['pdi'] ?? 0,
      // 'msiExpSvc': serviceTracking['msiExpSvc'] ?? 0,
      // 'stoExpSvc': serviceTracking['stoExpSvc'] ?? 0,
      'total': total,
      'updatedBy': saName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ======================================================
  /// GET TODAY SERVICE TRACKING
  /// ======================================================

  Future<Map<String, int>?> getTodayServiceTracking() async {
    final monthId = _getMonthId();
    final dateId = _getDateId();

    final doc = await firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('serviceTracking')
        .doc(dateId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    return {
      "booking": data["booking"] ?? 0,
      "pdi": data["pdi"] ?? 0,
      // "msiExpSvc": data["msiExpSvc"] ?? 0,
      // "stoExpSvc": data["stoExpSvc"] ?? 0,
    };
  }

  /// ======================================================
  /// GET TODAY SA DETAIL
  /// ======================================================

  Future<Map<String, dynamic>?> getTodaySaDetail(String saId) async {
    final monthId = _getMonthId();
    final dateId = _getDateId();

    final doc = await firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('entries')
        .doc(saId)
        .collection('detail')
        .doc(dateId)
        .get();

    if (!doc.exists) return null;
    return doc.data();
  }

  /// ======================================================
  /// UPDATE SERVICE TRACKING ONLY (with booking delta)
  /// ======================================================

  Future<void> updateServiceTrackingOnly({
    required Map<String, int> serviceTracking,
    required String saName,
  }) async {
    final monthId = _getMonthId();
    final dateId = _getDateId();

    final docRef = firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('serviceTracking')
        .doc(dateId);

    // Get old booking to calculate delta
    final oldDoc = await docRef.get();
    final oldBooking = oldDoc.exists
        ? ((oldDoc.data()?['booking'] ?? 0) as num).toInt()
        : 0;
    final newBooking = serviceTracking['booking'] ?? 0;
    final bookingDelta = newBooking - oldBooking;

    final total =
        (serviceTracking['booking'] ?? 0) + (serviceTracking['pdi'] ?? 0);
    // (serviceTracking['msiExpSvc'] ?? 0) +
    // (serviceTracking['stoExpSvc'] ?? 0);

    await docRef.set({
      'booking': serviceTracking['booking'] ?? 0,
      'pdi': serviceTracking['pdi'] ?? 0,
      // 'msiExpSvc': serviceTracking['msiExpSvc'] ?? 0,
      // 'stoExpSvc': serviceTracking['stoExpSvc'] ?? 0,
      'total': total,
      'updatedBy': saName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update monthly header with booking delta
    if (bookingDelta != 0) {
      final headerRef = firestore.collection('saperformance').doc(monthId);
      final headerSnapshot = await headerRef.get();
      if (headerSnapshot.exists) {
        await headerRef.update({
          'booking': FieldValue.increment(bookingDelta),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// ======================================================
  /// Update Daily Summary
  /// ======================================================

  Future<void> updateDailyHeader({
    required int unitEntry,
    required Map<String, int> penjualan,
    Map<String, dynamic>? oldData,
  }) async {
    final monthId = _getMonthId();
    final dateId = _getDateId();

    final docRef = firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('daily')
        .doc(dateId);

    int lc = penjualan['lc'] ?? 0;
    int oil = penjualan['oil'] ?? 0;
    int sorder = penjualan['sOrder'] ?? 0;
    int smaterial = penjualan['sMaterial'] ?? 0;
    int spart = penjualan['sPart'] ?? 0;
    int totalUnitEntry = unitEntry;

    if (oldData != null) {
      totalUnitEntry = unitEntry - ((oldData['unitEntry'] ?? 0) as num).toInt();
      final oldP = oldData['penjualan'] as Map<String, dynamic>? ?? {};
      lc = lc - ((oldP['lc'] ?? 0) as num).toInt();
      oil = oil - ((oldP['oil'] ?? 0) as num).toInt();
      sorder = sorder - ((oldP['sOrder'] ?? 0) as num).toInt();
      smaterial = smaterial - ((oldP['sMaterial'] ?? 0) as num).toInt();
      spart = spart - ((oldP['sPart'] ?? 0) as num).toInt();
    }

    final totalPenjualan = lc + oil + sorder + smaterial + spart;

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'dateId': dateId,
        'totalUnitEntry': totalUnitEntry,
        'lc': lc,
        'oil': oil,
        'sOrder': sorder,
        'sMaterial': smaterial,
        'sPart': spart,
        'totalPenjualan': totalPenjualan,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'totalUnitEntry': FieldValue.increment(totalUnitEntry),
        'lc': FieldValue.increment(lc),
        'oil': FieldValue.increment(oil),
        'sOrder': FieldValue.increment(sorder),
        'sMaterial': FieldValue.increment(smaterial),
        'sPart': FieldValue.increment(spart),
        'totalPenjualan': FieldValue.increment(totalPenjualan),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// ======================================================
  /// Update Header
  /// ======================================================

  Future<void> updateMonthlyHeader({
    required int unitEntry,
    required Map<String, int> penjualan,
    required int booking,
    Map<String, dynamic>? oldData,
    int? oldBooking,
  }) async {
    final now = DateTime.now();
    final monthId = _getMonthId();

    final docRef = firestore.collection('saperformance').doc(monthId);

    int lc = penjualan['lc'] ?? 0;
    int oil = penjualan['oil'] ?? 0;
    int sorder = penjualan['sOrder'] ?? 0;
    int smaterial = penjualan['sMaterial'] ?? 0;
    int spart = penjualan['sPart'] ?? 0;
    int totalUnitEntry = unitEntry;
    int bookingDelta = booking;

    if (oldData != null) {
      totalUnitEntry = unitEntry - ((oldData['unitEntry'] ?? 0) as num).toInt();
      final oldP = oldData['penjualan'] as Map<String, dynamic>? ?? {};
      lc = lc - ((oldP['lc'] ?? 0) as num).toInt();
      oil = oil - ((oldP['oil'] ?? 0) as num).toInt();
      sorder = sorder - ((oldP['sOrder'] ?? 0) as num).toInt();
      smaterial = smaterial - ((oldP['sMaterial'] ?? 0) as num).toInt();
      spart = spart - ((oldP['sPart'] ?? 0) as num).toInt();
      if (oldBooking != null) {
        bookingDelta = booking - oldBooking;
      } else {
        // If updating whole SA performance, booking might not be in oldData if it's separate.
        // But here we usually pass booking from the current input.
        bookingDelta =
            0; // Avoid double counting if not specifically tracking booking update here
      }
    }

    final totalPenjualan = lc + oil + sorder + smaterial + spart;

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'monthId': monthId,
        'year': now.year,
        'month': now.month,
        'totalUnitEntry': totalUnitEntry,
        'booking': bookingDelta,
        'penjualan': {
          'lc': lc,
          'oil': oil,
          'sOrder': sorder,
          'sMaterial': smaterial,
          'sPart': spart,
          'total': totalPenjualan,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'totalUnitEntry': FieldValue.increment(totalUnitEntry),
        'booking': FieldValue.increment(bookingDelta),

        'penjualan.lc': FieldValue.increment(lc),
        'penjualan.oil': FieldValue.increment(oil),
        'penjualan.sOrder': FieldValue.increment(sorder),
        'penjualan.sMaterial': FieldValue.increment(smaterial),
        'penjualan.sPart': FieldValue.increment(spart),
        'penjualan.total': FieldValue.increment(totalPenjualan),

        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

/// ======================================================
/// NOTIFIER
/// ======================================================

class SaPerformanceSaveNotifier extends StateNotifier<AsyncValue<void>> {
  final SaPerformanceRepository repository;

  SaPerformanceSaveNotifier(this.repository) : super(const AsyncData(null));

  Future<void> save({
    required String saId,
    required String saName,
    required int unitEntry,
    required Map<String, int> penjualan,
    required Map<String, int> hpp,
    required Map<String, int> serviceTracking,
    Map<String, dynamic>? oldData,
    int? oldBooking,
  }) async {
    state = const AsyncLoading();

    try {
      await repository.saveSaPerformance(
        saId: saId,
        saName: saName,
        unitEntry: unitEntry,
        penjualan: penjualan,
        hpp: hpp,
        oldData: oldData,
      );

      await repository.saveServiceTracking(
        saName: saName,
        serviceTracking: serviceTracking,
      );

      await repository.updateMonthlyHeader(
        unitEntry: unitEntry,
        penjualan: penjualan,
        booking: serviceTracking['booking'] ?? 0,
        oldData: oldData,
        oldBooking: oldBooking,
      );

      await repository.updateDailyHeader(
        unitEntry: unitEntry,
        penjualan: penjualan,
        oldData: oldData,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> saveServiceTrackingOnly({
    required String saName,
    required Map<String, int> serviceTracking,
  }) async {
    state = const AsyncLoading();
    try {
      await repository.updateServiceTrackingOnly(
        saName: saName,
        serviceTracking: serviceTracking,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
