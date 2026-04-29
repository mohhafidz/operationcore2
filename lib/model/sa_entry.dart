class SAEntry {
  final String userId;
  final int lc;
  final int so;
  final int oil;
  final int sm;
  final int spart;
  final int total;
  final int siu;
  final int revenue;

  SAEntry({
    required this.userId,
    required this.lc,
    required this.so,
    required this.oil,
    required this.sm,
    required this.spart,
    required this.total,
    required this.siu,
    required this.revenue,
  });

  factory SAEntry.empty(String userId) {
    return SAEntry(
      userId: userId,
      lc: 0,
      so: 0,
      oil: 0,
      sm: 0,
      spart: 0,
      total: 0,
      siu: 0,
      revenue: 0,
    );
  }

  factory SAEntry.fromMap(Map<String, dynamic> map, String userId) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return 0;
    }

    return SAEntry(
      userId: userId,
      lc: toInt(map['penjualan.lc']),
      so: toInt(map['penjualan.sOrder']),
      oil: toInt(map['penjualan.oil']),
      sm: toInt(map['penjualan.sMaterial']),
      spart: toInt(map['penjualan.sPart']),
      total: toInt(map['penjualan.total']),
      siu: toInt(map['unitEntry']),
      revenue: toInt(map['penjualan.total']),
    );
  }
}
