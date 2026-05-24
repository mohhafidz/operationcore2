import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class TargetAchievementRepository {
  final FirebaseFirestore firestore;

  TargetAchievementRepository(this.firestore);

  Stream<Map<String, dynamic>> streamTargetAchievementData() {
    final now = DateTime.now();
    final monthId = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    return firestore
        .collection('user')
        .where('role', isEqualTo: 'SA')
        .snapshots()
        .switchMap((saSnapshot) {
          final saList = saSnapshot.docs
              .map((doc) => {'id': doc.id, 'name': doc.data()['name'] ?? ''})
              .toList();

          if (saList.isEmpty) {
            return Stream.value({
              'saList': saList,
              'target': null,
              'details': <String, List<Map<String, dynamic>>>{},
            });
          }

          final targetStream = firestore
              .collection('target')
              .doc(monthId)
              .snapshots();

          final detailStreams = saList.map((sa) {
            final saId = sa['id']!;
            return firestore
                .collection('saperformance')
                .doc(monthId)
                .collection('entries')
                .doc(saId)
                .collection('detail')
                .snapshots()
                .map(
                  (snap) =>
                      MapEntry(saId, snap.docs.map((d) => d.data()).toList()),
                );
          }).toList();

          return Rx.combineLatest2(
            targetStream,
            Rx.combineLatest(
              detailStreams,
              (entries) => Map.fromEntries(entries),
            ),
            (targetSnap, detailsMap) {
              return {
                'saList': saList,
                'target': targetSnap.data(),
                'details': detailsMap,
              };
            },
          );
        });
  }
}
