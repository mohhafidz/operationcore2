import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/model/alluser.dart';
import 'package:operationcore2/providers/dashboard_provider.dart';
import 'package:operationcore2/repository/productifity_repository.dart';

String _getMonthId() {
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}";
}

/// REPOSITORY PROVIDER
final productifityRepositoryProvider = Provider<ProductifityRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return ProductifityRepository(firestore);
});

/// STREAM USERS GROUPED BY ROLE
final usersGroupedByRoleProvider = StreamProvider<Map<String, List<alluser>>>((
  ref,
) {
  final repo = ref.read(productifityRepositoryProvider);
  return repo.streamUsersGroupedByRole();
});

/// TARGET MEKANIK
final targetProvider = StreamProvider<int>((ref) {
  return ref
      .read(productifityRepositoryProvider)
      .streamTarget(docId: _getMonthId());
});

/// ✅ TAMBAHAN: PRODUCTIVITY STREAM — ini yang hilang!
final productivityProvider = StreamProvider<Map<String, Map<String, dynamic>>>((
  ref,
) {
  return ref
      .read(productifityRepositoryProvider)
      .streamProductivity(docId: _getMonthId());
});
