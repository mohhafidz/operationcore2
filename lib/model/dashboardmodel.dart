class DashboardData {
  final int siuTarget;
  final int siuActual;

  final int oilTarget;
  final int oilActual;

  final int jasaTarget;
  final int jasaActual;

  final int partTarget;
  final int partActual;

  final int materialTarget;
  final int materialActual;

  final int bookingTarget;
  final int bookingActual;

  final int sorderTarget;
  final int sorderActual;

  final int totalTarget;
  final int totalActual;

  final double siuAchv;
  final double jasaAchv;
  final double oilAchv;
  final double partAchv;
  final double soAchv;
  final double smAchv;
  final double bookingAchv;
  final double totalAchv;

  final int dailySiu;
  final int dailyJasa;
  final int dailyOil;
  final int dailyPart;
  final int dailySorder;
  final int dailyMaterial;
  final int dailyTotal;
  final int dailyBooking;

  DashboardData({
    required this.siuTarget,
    required this.siuActual,
    required this.oilTarget,
    required this.oilActual,
    required this.jasaTarget,
    required this.jasaActual,
    required this.partTarget,
    required this.partActual,
    required this.materialTarget,
    required this.materialActual,
    required this.bookingTarget,
    required this.bookingActual,
    required this.sorderTarget,
    required this.sorderActual,
    required this.totalTarget,
    required this.totalActual,
    required this.siuAchv,
    required this.jasaAchv,
    required this.oilAchv,
    required this.partAchv,
    required this.soAchv,
    required this.smAchv,
    required this.bookingAchv,
    required this.totalAchv,
    required this.dailySiu,
    required this.dailyJasa,
    required this.dailyOil,
    required this.dailyPart,
    required this.dailySorder,
    required this.dailyMaterial,
    required this.dailyTotal,
    required this.dailyBooking,
  });
}
