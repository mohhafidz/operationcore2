int getWorkingDayIndex({required List<String> holidays}) {
  final now = DateTime.now();

  int workingDayCount = 0;

  for (int i = 1; i <= now.day; i++) {
    final date = DateTime(now.year, now.month, i);

    final formatted = "${date.year}-${date.month}-${date.day}";

    final isSunday = date.weekday == DateTime.sunday;
    final isHoliday = holidays.contains(formatted);

    if (!isSunday && !isHoliday) {
      workingDayCount++;
    }
  }

  return workingDayCount;
}

int countWorkingDays({
  required int year,
  required int month,
  required List<DateTime> holidays,
}) {
  int totalWorkingDays = 0;

  final totalDaysInMonth = DateTime(year, month + 1, 0).day;

  for (int day = 1; day <= totalDaysInMonth; day++) {
    final currentDate = DateTime(year, month, day);

    if (currentDate.weekday == DateTime.sunday) continue;

    final isHoliday = holidays.any(
      (holiday) =>
          holiday.year == currentDate.year &&
          holiday.month == currentDate.month &&
          holiday.day == currentDate.day,
    );

    if (!isHoliday) {
      totalWorkingDays++;
    }
  }

  return totalWorkingDays;
}

int sisaharikerja({required int jumlahharikerja, required int harikerja}) {
  return jumlahharikerja - harikerja;
}

/// helper parsing
DateTime parseDate(String date) {
  final split = date.split("-");
  return DateTime(
    int.parse(split[0]),
    int.parse(split[1]),
    int.parse(split[2]),
  );
}
