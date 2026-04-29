import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/model/alluser.dart';
// import 'package:flutter_riverpod/legacy.dart';
import 'package:operationcore2/model/targetcardmodel.dart';
import '../repository/target_repository.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final targetRepositoryProvider = Provider(
  (ref) => TargetRepository(ref.read(firestoreProvider)),
);

final userRepositoryProvider = Provider<TargetRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return TargetRepository(firestore);
});

final mekanikProvider = StreamProvider<List<alluser>>((ref) {
  final repo = ref.read(userRepositoryProvider);
  return repo.watchMekanik();
});
final SAProvider = StreamProvider<List<alluser>>((ref) {
  final repo = ref.read(userRepositoryProvider);
  return repo.watchSA();
});
final LeaderProvider = StreamProvider<List<alluser>>((ref) {
  final repo = ref.read(userRepositoryProvider);
  return repo.watchLeader();
});
final CSProvider = StreamProvider<List<alluser>>((ref) {
  final repo = ref.read(userRepositoryProvider);
  return repo.watchCS();
});
//  Rachel90, CS, MK, S, L - internal codenames should match these.

/// Provider to load existing target data for the current month
final existingTargetProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final repo = ref.read(targetRepositoryProvider);
  final now = DateTime.now();
  final docId = "${now.year}-${now.month.toString().padLeft(2, '0')}";

  final exists = await repo.targetExists(docId);
  if (!exists) return null;

  final header = await repo.getTargetHeader(docId);
  final penjualanUnit = await repo.getTargetDetail(
    docId: docId,
    category: "penjualan (unit)",
  );
  final totalPenjualanRp = await repo.getTargetDetail(
    docId: docId,
    category: "total penjualan (Rp)",
  );
  final prevMonth = await repo.getPreviousData("month");
  final prevYear = await repo.getPreviousData("year");

  return {
    "header": header,
    "penjualan (unit)": penjualanUnit,
    "total penjualan (Rp)": totalPenjualanRp,
    "prev_month": prevMonth,
    "prev_year": prevYear,
  };
});

Future<void> saveAllTargets(
  WidgetRef ref,
  List<TargetCardModel> cards,
  int targetCS,
  int workingDays,
  List<String> holidays,
) async {
  final repo = ref.read(targetRepositoryProvider);

  final now = DateTime.now();
  final docId = "${now.year}-${now.month.toString().padLeft(2, '0')}";

  int siu = 0;
  int jasa = 0;
  int oil = 0;
  int part = 0;
  int so = 0;
  int sm = 0;
  int total = 0;

  for (var card in cards) {
    if (card.title == "Penjualan (Unit)") {
      for (var item in card.items) {
        if (item.name == "Total Penjualan (Q)") {
          siu = int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
        }
      }
    } else if (card.title == "Total Penjualan (Rp)") {
      for (var item in card.items) {
        if (item.name == "Jasa Bengkel") {
          jasa = int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
        } else if (item.name == "Oil") {
          oil = int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
        } else if (item.name == "Spare Part") {
          part = int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
        } else if (item.name == "Sub Order") {
          so = int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
        } else if (item.name == "Sub Material") {
          sm = int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
        } else if (item.name == "Total Penjualan (RP)") {
          total = int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
        }
      }
    }
  }

  final totalMK = await repo.getTotalMK();
  final totalSA = await repo.getTotalSA();

  int targetmekanik = 0;
  if (totalMK > 0) {
    targetmekanik = (jasa / totalMK).round();
  }

  int targetSiupersa = 0;
  int targetJasapersa = 0;
  int targetOilpersa = 0;
  int targetPartpersa = 0;
  int targetSorderpersa = 0;
  int targetMaterialpersa = 0;
  int revenuepersa = 0;

  if (totalSA > 0) {
    targetSiupersa = (siu / totalSA).round();
    targetJasapersa = (jasa / totalSA).round();
    targetOilpersa = (oil / totalSA).round();
    targetPartpersa = (part / totalSA).round();
    targetSorderpersa = (so / totalSA).round();
    targetMaterialpersa = (sm / totalSA).round();
    revenuepersa = (total / totalSA).round();
  }

  /// save header
  await repo.saveTargetHeader(
    docId: docId,
    targetbooking: targetCS,
    workingDays: workingDays,
    holidays: holidays,
    siu: siu,
    jasa: jasa,
    oil: oil,
    part: part,
    so: so,
    sm: sm,
    total: total,
    targetmekanik: targetmekanik,
    targetSiupersa: targetSiupersa,
    targetJasapersa: targetJasapersa,
    targetOilpersa: targetOilpersa,
    targetPartpersa: targetPartpersa,
    targetSorderpersa: targetSorderpersa,
    targetMaterialpersa: targetMaterialpersa,
    revenuepersa: revenuepersa,
  );

  for (var card in cards) {
    Map<String, dynamic> data = {};

    for (var item in card.items) {
      final text = item.controller.text;

      if (item.ispercentage || item.isdecimal) {
        data[item.name] = double.tryParse(text) ?? 0.0;
      } else if (item.iscurrency) {
        data[item.name] = int.tryParse(text.replaceAll('.', '')) ?? 0;
      } else {
        final number = int.tryParse(text);
        data[item.name] = number ?? 0;
      }
    }

    /// DATA BULAN SEBELUMNYA
    if (card.title == "INPUT DATA BULAN SEBELUMNYA") {
      await repo.savePreviousData(type: "month", data: data);
      continue;
    }

    /// DATA TAHUN SEBELUMNYA
    if (card.title == "INPUT DATA TAHUN SEBELUMNYA") {
      await repo.savePreviousData(type: "year", data: data);
      continue;
    }

    /// DATA TARGET
    String category = _mapCategory(card.title);
    if (category != "unknown") {
      await repo.saveTargetDetail(docId: docId, category: category, data: data);
    }
  }

  await repo.saveproductivity(docId: docId);
}

String _mapCategory(String title) {
  switch (title) {
    case "Penjualan (Unit)":
      return "penjualan (unit)";

    case "Total Penjualan (Rp)":
      return "total penjualan (Rp)";

    default:
      return "unknown";
  }
}
