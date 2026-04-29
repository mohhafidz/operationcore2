import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:operationcore2/model/dashboardmodel.dart';
import 'package:operationcore2/model/databulansebelum.dart';
import 'package:operationcore2/model/datatahunsebelum.dart';
import 'package:rxdart/rxdart.dart';

class DashboardRepository {
  final FirebaseFirestore firestore;

  DashboardRepository(this.firestore);

  String _getMonthId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  String _getDateId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  int _getPenjualan(Map<String, dynamic> p, String key) {
    final penjualan = Map<String, dynamic>.from(p['penjualan'] ?? {});
    return penjualan[key] ?? 0;
  }

  Stream<Databulansebelum> streamDataBulanSebelum() {
    return firestore.collection('datasebelum').doc('month').snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      return Databulansebelum(
        siu: data['SIU (Units)'] ?? 0,
        jasa: data['Jasa (Revenue)'] ?? 0,
        oil: data['Oil (Revenue)'] ?? 0,
        part: data['Part (Revenue)'] ?? 0,
        so: data['SO (Revenue)'] ?? 0,
        sm: data['SM (Revenue)'] ?? 0,
        total: data['Total (Revenue)'] ?? 0,
        booking: data['Booking (Quantity)'] ?? 0,
      );
    });
  }

  Stream<Datatahunsebelum> streamDataTahunSebelum() {
    return firestore.collection('datasebelum').doc('year').snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      return Datatahunsebelum(
        siu: data['SIU (Units)'] ?? 0,
        jasa: data['Jasa (Revenue)'] ?? 0,
        oil: data['Oil (Revenue)'] ?? 0,
        part: data['Part (Revenue)'] ?? 0,
        so: data['SO (Revenue)'] ?? 0,
        sm: data['SM (Revenue)'] ?? 0,
        total: data['Total (Revenue)'] ?? 0,
        booking: data['Booking (Quantity)'] ?? 0,
      );
    });
  }

  Stream<DashboardData> streamDashboard() {
    final monthId = _getMonthId();
    final date = _getDateId();

    final targetDetailStream = firestore
        .collection('target')
        .doc(monthId)
        .collection('detail')
        .snapshots();

    final targetRootStream = firestore
        .collection('target')
        .doc(monthId)
        .snapshots();

    final performanceStream = firestore
        .collection('saperformance')
        .doc(monthId)
        .snapshots();

    final avrgStream = firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('daily')
        .doc(date)
        .snapshots();

    final serviceTrackingStream = firestore
        .collection('saperformance')
        .doc(monthId)
        .collection('serviceTracking')
        .doc(date)
        .snapshots();

    return Rx.combineLatest5(
      targetRootStream,
      targetDetailStream,
      performanceStream,
      avrgStream,
      serviceTrackingStream,
      (
        DocumentSnapshot targetRoot,
        QuerySnapshot targetSnap,
        DocumentSnapshot performanceDoc,
        DocumentSnapshot avrgSnap,
        DocumentSnapshot serviceTrackingSnap,
      ) {
        final root = targetRoot.data() as Map<String, dynamic>? ?? {};
        final p = performanceDoc.data() as Map<String, dynamic>? ?? {};
        final avrg = avrgSnap.data() as Map<String, dynamic>? ?? {};
        final serviceTracking =
            serviceTrackingSnap.data() as Map<String, dynamic>? ?? {};

        return DashboardData(
          // ================= SIU =================
          siuTarget: root['SIU'] ?? 0,
          siuActual: p['totalUnitEntry'] ?? 0,

          // ================= PENJUALAN Q =================
          oilTarget: root['Oil'] ?? 0,
          oilActual: _getPenjualan(p, 'oil'),

          partTarget: root['Part'] ?? 0,
          partActual: _getPenjualan(p, 'sPart'),

          jasaTarget: root['Jasa'] ?? 0,
          jasaActual: _getPenjualan(p, 'lc'),

          sorderTarget: root['SO'] ?? 0,
          sorderActual: _getPenjualan(p, 'sOrder'),

          // ================= PENJUALAN RP =================
          materialTarget: root['SM'] ?? 0,
          materialActual: _getPenjualan(p, 'sMaterial'),

          // ================= OTHER =================
          bookingTarget: root['targetBooking'] ?? 0,
          bookingActual: p['booking'] ?? 0,

          totalTarget: root['total'] ?? 0,
          totalActual: _getPenjualan(p, 'total'),

          // ================= siu Achv =================
          siuAchv: calculateProgress(
            p['totalUnitEntry'] ?? 0,
            root['SIU'] ?? 0,
          ),

          // ================= jasa Achv =================
          jasaAchv: calculateProgress(
            _getPenjualan(p, 'lc'),
            root['Jasa'] ?? 0,
          ),

          // ================= oil Achv =================
          oilAchv: calculateProgress(_getPenjualan(p, 'oil'), root['Oil'] ?? 0),

          // ================= part Achv =================
          partAchv: calculateProgress(
            _getPenjualan(p, 'sPart'),
            root['Part'] ?? 0,
          ),

          // ================= so Achv =================
          soAchv: calculateProgress(
            _getPenjualan(p, 'sOrder'),
            root['SO'] ?? 0,
          ),

          // ================= sm Achv =================
          smAchv: calculateProgress(
            _getPenjualan(p, 'sMaterial'),
            root['SM'] ?? 0,
          ),

          // ================= booking Achv =================
          bookingAchv: calculateProgress(
            p['booking'] ?? 0,
            root['targetBooking'] ?? 0,
          ),

          // ================= total Achv =================
          totalAchv: calculateProgress(
            _getPenjualan(p, 'total'),
            root['total'] ?? 0,
          ),

          dailySiu: avrg['totalUnitEntry'] ?? 0,
          dailyJasa: avrg['lc'] ?? 0,
          dailyOil: avrg['oil'] ?? 0,
          dailyPart: avrg['sPart'] ?? 0,
          dailySorder: avrg['sOrder'] ?? 0,
          dailyMaterial: avrg['sMaterial'] ?? 0,
          dailyTotal: avrg['totalPenjualan'] ?? 0,
          dailyBooking: serviceTracking['booking'] ?? 0,
        );
      },
    );
  }

  double calculateProgress(int actual, int target) {
    if (target == 0) return 0;
    return (actual / target) * 100;
  }

  Stream<List<String>> streamHolidays() {
    final monthId = _getMonthId();

    return firestore.collection('target').doc(monthId).snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return List<String>.from(data['holidays'] ?? []);
    });
  }
}
