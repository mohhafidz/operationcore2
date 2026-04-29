import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:operationcore2/model/appuser.dart';

class AuthRepository {
  final FirebaseFirestore firestore;

  AuthRepository(this.firestore);

  Future<AppUser?> login({
    required String username,
    required String password,
  }) async {
    final query = await firestore
        .collection('user')
        .where('email', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    final doc = query.docs.first;
    final data = doc.data();

    final passwordHash = data['password'];

    final isValid = BCrypt.checkpw(password, passwordHash);

    if (!isValid) {
      return null;
    }

    return AppUser.fromFirestore(doc.id, data);
  }
}
