import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:operationcore2/model/ProductivityField%20.dart';
import 'package:operationcore2/model/alluser.dart';

class ProductifityRepository {
  final FirebaseFirestore firestore;
  ProductifityRepository(this.firestore);

  Stream<Map<String, List<alluser>>> streamUsersGroupedByRole() {
    return firestore.collection('user').snapshots().map((snapshot) {
      final Map<String, List<alluser>> grouped = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final user = alluser.fromFirestore(doc.id, data);
        if (user.role.toLowerCase() == 'admin') continue;
        grouped.putIfAbsent(user.role, () => []).add(user);
      }
      return grouped;
    });
  }

  Stream<int> streamTarget({required String docId}) {
    return firestore
        .collection('target')
        .doc(docId)
        .snapshots()
        .map((doc) => doc.data()?['targetmekanik'] ?? 0);
  }

  Stream<Map<String, Map<String, dynamic>>> streamProductivity({
    required String docId,
  }) {
    return firestore
        .collection('productivity')
        .doc(docId)
        .collection('detail')
        .snapshots()
        .map((snapshot) {
          final result = <String, Map<String, dynamic>>{};
          for (var doc in snapshot.docs) {
            result[doc.id] = doc.data();
          }
          return result;
        });
  }

  Future<void> updateProductivityValue({
    required String docId,
    required String userId,
    required ProductivityField field,
    required int value,
  }) async {
    final fieldName = fieldToString(field);
    final batch = firestore.batch();

    // 1. Dapatkan role user yang di-update
    final userDoc = await firestore.collection('user').doc(userId).get();
    final role = (userDoc.data()?['role'] ?? '').toString().toUpperCase();

    // 2. Referensi dokumen user itu sendiri
    final docRef = firestore
        .collection('productivity')
        .doc(docId)
        .collection('detail')
        .doc(userId);

    batch.set(docRef, {
      fieldName: value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 3. Jika yang di-update adalah MEKANIK (MK), update juga data ke LEADER (LD)
    if (role == 'MK') {
      // Ambil semua daftar mekanik dari koleksi user
      final mechanicsSnapshot = await firestore
          .collection('user')
          .where('role', isEqualTo: 'MK')
          .get();
      final mechanicIds = mechanicsSnapshot.docs.map((d) => d.id).toSet();

      // Ambil data detail produktivitas saat ini untuk semua mekanik
      final detailsSnapshot = await firestore
          .collection('productivity')
          .doc(docId)
          .collection('detail')
          .get();

      int totalSum = 0;
      bool userIncluded = false;

      for (var doc in detailsSnapshot.docs) {
        if (mechanicIds.contains(doc.id)) {
          if (doc.id == userId) {
            totalSum += value; // Gunakan nilai baru
            userIncluded = true;
          } else {
            totalSum += (doc.data()[fieldName] ?? 0) as int;
          }
        }
      }

      // Jika user belum pernah punya record sebelumnya
      if (!userIncluded) {
        totalSum += value;
      }

      // Ambil semua daftar Leader
      final leadersSnapshot = await firestore
          .collection('user')
          .where('role', isEqualTo: 'LD')
          .get();

      // Update setiap leader dengan total penjumlahan mekanik
      for (var leaderDoc in leadersSnapshot.docs) {
        final leaderRef = firestore
            .collection('productivity')
            .doc(docId)
            .collection('detail')
            .doc(leaderDoc.id);

        batch.set(leaderRef, {
          fieldName: totalSum,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    await batch.commit();
  }
}
