class TargetModel {
  // final int revenue;
  // final int jasa;
  // final int material;
  // final int oil;
  // final int part;
  // final int sorder;
  // final int mekanik;
  // final int siu;
  // final int lc;
  final int lc;
  final int oil;
  final int sparepart;
  final int sorder;
  final int smaterial;
  final int revenue;
  final int siu;

  TargetModel({
    required this.revenue,
    required this.lc,
    required this.oil,
    required this.sparepart,
    required this.sorder,
    required this.smaterial,
    required this.siu,
  });

  factory TargetModel.empty() {
    return TargetModel(
      revenue: 0,
      lc: 0,
      oil: 0,
      sparepart: 0,
      sorder: 0,
      smaterial: 0,
      siu: 0,
    );
  }

  factory TargetModel.fromMap(Map<String, dynamic> map) {
    return TargetModel(
      revenue: map['revenuepersa'] ?? 0,
      lc: map['targetJasapersa'] ?? 0,
      oil: map['targetOilpersa'] ?? 0,
      sparepart: map['targetPartpersa'] ?? 0,
      sorder: map['targetSorderpersa'] ?? 0,
      smaterial: map['targetMaterialpersa'] ?? 0,
      siu: map['targetSiupersa'] ?? 0,
    );
  }
}
