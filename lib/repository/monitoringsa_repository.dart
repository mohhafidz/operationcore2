import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:operationcore2/model/sa_entry.dart';
import 'package:operationcore2/model/target_model.dart';

class SARepository {
  final FirebaseFirestore firestore;

  SARepository(this.firestore);

  /// GET ALL ENTRIES DALAM 1 BULAN
  Stream<List<SAEntry>> watchEntriesByMonth(String yearMonth) {
    return firestore
        .collection("saperformance")
        .doc(yearMonth)
        .collection("entries")
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SAEntry.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// TARGET GLOBAL
  Future<TargetModel> getTarget(String yearMonth) async {
    final doc = await firestore.collection("target").doc(yearMonth).get();

    if (!doc.exists) return TargetModel.empty();

    return TargetModel.fromMap(doc.data()!);
  }
}
