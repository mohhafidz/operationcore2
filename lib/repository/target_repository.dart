import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:operationcore2/model/alluser.dart';

class TargetRepository {
  final FirebaseFirestore firestore;

  TargetRepository(this.firestore);

  Future<void> saveTargetDetail({
    required String docId,
    required String category,
    required Map<String, dynamic> data,
  }) async {
    await firestore
        .collection("target")
        .doc(docId)
        .collection("detail")
        .doc(category)
        .set(data);
  }

  Future<void> saveTargetHeader({
    required String docId,
    required int targetbooking,
    required int workingDays,
    required List<String> holidays,
    required int siu,
    required int jasa,
    required int oil,
    required int part,
    required int so,
    required int sm,
    required int total,
    required int targetmekanik,
    required int targetSiupersa,
    required int targetJasapersa,
    required int targetOilpersa,
    required int targetPartpersa,
    required int targetSorderpersa,
    required int targetMaterialpersa,
    required int revenuepersa,
  }) async {
    await firestore.collection("target").doc(docId).set({
      "targetBooking": targetbooking,
      "working_days": workingDays,
      "holidays": holidays,
      "SIU": siu,
      "Jasa": jasa,
      "Oil": oil,
      "Part": part,
      "SO": so,
      "SM": sm,
      "total": total,
      "targetmekanik": targetmekanik,
      "targetSiupersa": targetSiupersa,
      "targetJasapersa": targetJasapersa,
      "targetOilpersa": targetOilpersa,
      "targetPartpersa": targetPartpersa,
      "targetSorderpersa": targetSorderpersa,
      "targetMaterialpersa": targetMaterialpersa,
      "revenuepersa": revenuepersa,
      "created_at": FieldValue.serverTimestamp(),
    });
  }

  Future<void> savePreviousData({
    required String type, // month / year
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection("datasebelum").doc(type).set(data);
  }

  /// Check if target exists for a given month (docId = "yyyy-MM")
  Future<bool> targetExists(String docId) async {
    final doc = await firestore.collection("target").doc(docId).get();
    return doc.exists;
  }

  /// Get target header data
  Future<Map<String, dynamic>?> getTargetHeader(String docId) async {
    final doc = await firestore.collection("target").doc(docId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Get target detail for a specific category
  Future<Map<String, dynamic>?> getTargetDetail({
    required String docId,
    required String category,
  }) async {
    final doc = await firestore
        .collection("target")
        .doc(docId)
        .collection("detail")
        .doc(category)
        .get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Get previous data (month / year)
  Future<Map<String, dynamic>?> getPreviousData(String type) async {
    final doc = await firestore.collection("datasebelum").doc(type).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<int> getTotalSA() async {
    final snapshot = await firestore
        .collection('user')
        .where('role', isEqualTo: 'SA')
        .get();

    return snapshot.docs.length;
  }

  Future<int> getTotalMK() async {
    final snapshot = await firestore
        .collection('user')
        .where('role', isEqualTo: 'MK')
        .get();

    return snapshot.docs.length;
  }

  Future<List<alluser>> getMekanik() async {
    final snapshot = await firestore
        .collection('user')
        .where('role', isEqualTo: 'MK')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return alluser(
        userId: doc.id,
        name: data['name'] ?? '',
        role: data['role'] ?? '',
      );
    }).toList();
  }

  Future<List<alluser>> getSA() async {
    final snapshot = await firestore
        .collection("user")
        .where("role", isEqualTo: "SA")
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return alluser(
        userId: doc.id, // 🔥 ini userId
        name: data['name'] ?? '',
        role: data['role'] ?? '',
      );
    }).toList();
  }

  Future<List<alluser>> getLeader() async {
    final snapshot = await firestore
        .collection("user")
        .where("role", isEqualTo: "LD")
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return alluser(
        userId: doc.id, // 🔥 ini userId
        name: data['name'] ?? '',
        role: data['role'] ?? '',
      );
    }).toList();
  }

  Future<List<alluser>> getCS() async {
    final snapshot =
        await firestore.collection("user").where("role", isEqualTo: "CS").get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return alluser(
        userId: doc.id, // 🔥 ini userId
        name: data['name'] ?? '',
        role: data['role'] ?? '',
      );
    }).toList();
  }

  Stream<List<alluser>> watchSA() {
    return firestore
        .collection("user")
        .where("role", isEqualTo: "SA")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return alluser(
          userId: doc.id,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
        );
      }).toList();
    });
  }

  Stream<List<alluser>> watchMekanik() {
    return firestore
        .collection("user")
        .where("role", isEqualTo: "MK")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return alluser(
          userId: doc.id,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
        );
      }).toList();
    });
  }

  Stream<List<alluser>> watchLeader() {
    return firestore
        .collection("user")
        .where("role", isEqualTo: "LD")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return alluser(
          userId: doc.id,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
        );
      }).toList();
    });
  }

  Stream<List<alluser>> watchCS() {
    return firestore
        .collection("user")
        .where("role", isEqualTo: "CS")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return alluser(
          userId: doc.id,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
        );
      }).toList();
    });
  }

  Future<void> saveproductivity({required String docId}) async {
    final allmekanik = await getMekanik();
    final allsa = await getSA();
    final allleader = await getLeader();
    final allcs = await getCS();

    for (var i = 0; i < allmekanik.length; i++) {
      await firestore
          .collection("productivity")
          .doc(docId)
          .collection('detail')
          .doc(allmekanik[i].userId)
          .set({
            'name': allmekanik[i].name,
            'totaljasa': 0,
            'unitentry': 0,
            'userId': allmekanik[i].userId,
          });
    }
    for (var i = 0; i < allsa.length; i++) {
      await firestore
          .collection("productivity")
          .doc(docId)
          .collection('detail')
          .doc(allsa[i].userId)
          .set({
            'name': allsa[i].name,
            // 'totaljasa': 0,
            'unitentry': 0,
            'userId': allsa[i].userId,
          });
    }
    for (var i = 0; i < allleader.length; i++) {
      await firestore
          .collection("productivity")
          .doc(docId)
          .collection('detail')
          .doc(allleader[i].userId)
          .set({
            'name': allleader[i].name,
            'totaljasa': 0,
            'unitentry': 0,
            'userId': allleader[i].userId,
          });
    }
    for (var i = 0; i < allcs.length; i++) {
      await firestore
          .collection("productivity")
          .doc(docId)
          .collection('detail')
          .doc(allcs[i].userId)
          .set({
            'name': allcs[i].name,
            // 'totaljasa': 0,
            'unitentry': 0,
            'userId': allcs[i].userId,
          });
    }
  }
}
