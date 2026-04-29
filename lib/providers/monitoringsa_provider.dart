import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:operationcore2/model/monitoringSAmodel.dart';
import 'package:operationcore2/model/sa_entry.dart';
import 'package:operationcore2/providers/target_provider.dart';
import 'package:operationcore2/repository/monitoringsa_repository.dart';

final firestoreProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

final saRepositoryProvider = Provider<SARepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return SARepository(firestore);
});

String _getMonthId() {
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}";
}

final monitoringSAProvider = StreamProvider<List<monitoringSAmodel>>((ref) {
  final repo = ref.read(saRepositoryProvider);
  final yearMonth = _getMonthId();

  // Watch the SA list stream (real-time)
  final saListAsync = ref.watch(SAProvider);

  // Watch the entries stream (real-time)
  return repo.watchEntriesByMonth(yearMonth).asyncMap((entries) async {
    // Get the current list of SAs from the stream
    final saList = saListAsync.value ?? [];
    
    final target = await repo.getTarget(yearMonth);
    final entryMap = {for (var e in entries) e.userId: e};

    return saList.map((sa) {
      final entry = entryMap[sa.userId] ?? SAEntry.empty(sa.userId);
      return monitoringSAmodel(sa: sa, entry: entry, target: target);
    }).toList();
  });
});
