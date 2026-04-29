import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bcrypt/bcrypt.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  // Mapping role to prefix
  String _getPrefix(String role) {
    switch (role.toLowerCase()) {
      case 'leader':
        return 'ld';
      case 'mekanik':
        return 'mk';
      case 'cs service':
        return 'cs';
      case 'sa':
        return 'sa';
      default:
        return 'usr';
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final prefix = _getPrefix(role);
    final counterRef = _firestore.collection('counters').doc('user_ids');
    print(prefix.toUpperCase());

    // Hash the password
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    try {
      // 1. Get current counter value
      final counterSnapshot = await counterRef.get();
      int currentCount = 0;

      if (counterSnapshot.exists) {
        final data = counterSnapshot.data() as Map<String, dynamic>;
        currentCount = data[prefix] ?? 0;
      }

      final nextCount = currentCount + 1;

      // 2. Update counter
      await counterRef.set({prefix: nextCount}, SetOptions(merge: true));

      // 3. Generate User ID (e.g., ld_001)
      final formattedId = nextCount.toString().padLeft(3, '0');
      final userID = "${prefix}_$formattedId";

      // 4. Save User Data (Using userID as Document ID)
      await _firestore.collection('user').doc(userID).set({
        'name': name,
        'email': email,
        'password': hashedPassword,
        'role': prefix.toUpperCase(), // Save as MK, SA, LD, or CS
        'userId': userID,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating user: $e");
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('user').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .where((user) => user['role'].toString().toLowerCase() != 'admin')
          .toList();
    });
  }

  Future<void> deleteUser(String id) async {
    return _firestore.collection('user').doc(id).delete();
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final userListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(userRepositoryProvider).getUsersStream();
});
