import 'package:operationcore2/model/alluser.dart';

Map<String, int> calculateMekanikTotals(
  List<alluser> mekanikUsers,
  Map<String, Map<String, dynamic>> productivityData,
) {
  int totalUnit = 0;
  int totalJasa = 0;

  for (var m in mekanikUsers) {
    final data = productivityData[m.userId] ?? {};
    totalUnit += (data['unitentry'] ?? 0) as int;
    totalJasa += (data['totaljasa'] ?? 0) as int;
  }

  return {'unitEntry': totalUnit, 'totalJasa': totalJasa};
}
