import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_charts/material_charts.dart';
import 'package:operationcore2/component/appcolor.dart';
import 'package:operationcore2/component/button.dart';
import 'package:operationcore2/component/card.dart';
import 'package:operationcore2/component/text/textbold.dart';
import 'package:operationcore2/component/text/textmessage.dart';
import 'package:operationcore2/component/text/texttitle.dart';
import 'package:operationcore2/model/alluser.dart';
import 'package:operationcore2/model/person.dart';
import 'package:operationcore2/model/targetcardmodel.dart';
import 'package:operationcore2/providers/dashboard_provider.dart';
import 'package:operationcore2/providers/target_provider.dart';
import 'package:operationcore2/providers/productifity_provider.dart';
import 'package:operationcore2/services/export_service.dart';
import 'package:operationcore2/utils/date_helper.dart';
import 'package:operationcore2/utils/number_formatter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final List<TargetCardModel> cards = [
  TargetCardModel(
    title: "Penjualan (Unit)",
    icon: "assets/Icon.png",
    items: [
      TargetItem(name: "Jasa Umum", iscurrency: false, ispercentage: false),
      TargetItem(name: "Free Service", iscurrency: false, ispercentage: false),
      TargetItem(
        name: "Warranty / Claim",

        iscurrency: false,
        ispercentage: false,
      ),
      TargetItem(name: "PDI", iscurrency: false, ispercentage: false),
      TargetItem(name: "Lain-lain", iscurrency: false, ispercentage: false),
      TargetItem(
        name: "Total Penjualan (Q)",

        iscurrency: false,
        ispercentage: false,
      ),
    ],
  ),
  TargetCardModel(
    title: "Total Penjualan (Rp)",
    icon: "assets/Icon-1.png",
    items: [
      TargetItem(name: "Jasa Bengkel", iscurrency: true, ispercentage: false),
      TargetItem(name: "Spare Part", iscurrency: true, ispercentage: false),
      TargetItem(name: "Oil", iscurrency: true, ispercentage: false),
      TargetItem(name: "Sub Order", iscurrency: true, ispercentage: false),
      TargetItem(name: "Sub Material", iscurrency: true, ispercentage: false),
      // TargetItem(name: "Lain-lain", iscurrency: true, ispercentage: false),
      TargetItem(
        name: "Total Penjualan (RP)",

        iscurrency: true,
        ispercentage: false,
      ),
    ],
  ),

  TargetCardModel(
    title: "INPUT DATA BULAN SEBELUMNYA",
    icon: "assets/Icon (3).png",
    items: [
      TargetItem(name: "SIU (Units)", iscurrency: false, ispercentage: false),
      TargetItem(name: "Jasa (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(name: "Oil (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(name: "Part (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(name: "SO (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(name: "SM (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(
        name: "Total (Revenue)",

        iscurrency: true,
        ispercentage: false,
      ),
      TargetItem(
        name: "Booking (Quantity)",

        iscurrency: false,
        ispercentage: false,
      ),
    ],
  ),
  TargetCardModel(
    title: "INPUT DATA TAHUN SEBELUMNYA",
    icon: "assets/Icon (4).png",
    items: [
      TargetItem(name: "SIU (Units)", iscurrency: false, ispercentage: false),
      TargetItem(name: "Jasa (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(name: "Oil (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(name: "Part (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(name: "SO (Revenue)", iscurrency: true, ispercentage: false),

      TargetItem(name: "SM (Revenue)", iscurrency: true, ispercentage: false),
      TargetItem(
        name: "Total (Revenue)",

        iscurrency: true,
        ispercentage: false,
      ),
      TargetItem(
        name: "Booking (Quantity)",

        iscurrency: false,
        ispercentage: false,
      ),
    ],
  ),
];

class Target extends ConsumerStatefulWidget {
  const Target({super.key});

  @override
  ConsumerState<Target> createState() => _TargetState();
}

class _TargetState extends ConsumerState<Target> {
  List<DateTime> selectedHolidays = [];
  final TextEditingController targetCSController = TextEditingController();
  final RxBool isloading = false.obs;
  bool _isEditMode = false;
  bool _dataLoaded = false;
  bool _hasDownloadedExcel = false;

  @override
  void initState() {
    super.initState();
    // Load will happen in build via the provider
  }

  @override
  void dispose() {
    targetCSController.dispose();
    super.dispose();
  }

  void _resetAllFields() {
    targetCSController.text = "0";

    for (var card in cards) {
      for (var item in card.items) {
        item.controller.text = "0";
      }
    }

    selectedHolidays.clear();
    setState(() {});
  }

  /// Populate fields from existing Firestore data
  void _populateFields(Map<String, dynamic> existingData) {
    final header = existingData["header"] as Map<String, dynamic>?;
    if (header != null) {
      targetCSController.text = (header["targetBooking"] ?? 0).toString();

      // Restore holidays
      final holidayList = header["holidays"] as List<dynamic>?;
      if (holidayList != null) {
        selectedHolidays = holidayList.map((h) {
          final parts = h.toString().split("-");
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }).toList();
      }
    }

    // Map card titles to data keys
    final categoryMap = {
      "Penjualan (Unit)": existingData["penjualan (unit)"],
      "Total Penjualan (Rp)": existingData["total penjualan (Rp)"],
      "INPUT DATA BULAN SEBELUMNYA": existingData["prev_month"],
      "INPUT DATA TAHUN SEBELUMNYA": existingData["prev_year"],
    };

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    for (var card in cards) {
      final data = categoryMap[card.title] as Map<String, dynamic>?;
      if (data == null) continue;

      for (var item in card.items) {
        final value = data[item.name];
        if (value != null) {
          if (item.ispercentage || item.isdecimal) {
            item.controller.text = value.toString();
          } else if (item.iscurrency) {
            // Format as currency with dot separator
            final intValue = (value is int) ? value : (value as num).toInt();
            item.controller.text = currencyFormatter.format(intValue);
          } else {
            item.controller.text = value.toString();
          }
        }
      }
    }
  }

  Future<bool?> _showSummaryDialog({
    required int workingDays,
    required List<DateTime> holidays,
    required int targetCS,
  }) {
    int siu = 0;
    int jasa = 0;
    int oil = 0;
    int part = 0;
    int so = 0;
    int sm = 0;
    int total = 0;

    ///data sebelumnya
    ///bulan kmrn
    int siuBulan = 0;
    int jasaBulan = 0;
    int oilBulan = 0;
    int partBulan = 0;
    int soBulan = 0;
    int smBulan = 0;
    int totalBulan = 0;
    int bookingBulan = 0;

    ///tahun kmrn
    int siuTahun = 0;
    int jasaTahun = 0;
    int oilTahun = 0;
    int partTahun = 0;
    int soTahun = 0;
    int smTahun = 0;
    int totalTahun = 0;
    int bookingTahun = 0;

    for (var card in cards) {
      if (card.title == "Penjualan (Unit)") {
        for (var item in card.items) {
          if (item.name == "Total Penjualan (Q)") {
            siu = int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
          }
        }
      } else if (card.title == "Total Penjualan (Rp)") {
        for (var item in card.items) {
          final val =
              int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
          if (item.name == "Jasa Bengkel") {
            jasa = val;
          } else if (item.name == "Oil") {
            oil = val;
          } else if (item.name == "Spare Part") {
            part = val;
          } else if (item.name == "Sub Order") {
            so = val;
          } else if (item.name == "Sub Material") {
            sm = val;
          } else if (item.name == "Total Penjualan (RP)") {
            total = val;
          }
        }
      } else if (card.title == "INPUT DATA BULAN SEBELUMNYA") {
        for (var item in card.items) {
          final val =
              int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
          if (item.name == "SIU (Units)") {
            siuBulan = val;
          } else if (item.name == "Jasa (Revenue)") {
            jasaBulan = val;
          } else if (item.name == "Oil (Revenue)") {
            oilBulan = val;
          } else if (item.name == "Part (Revenue)") {
            partBulan = val;
          } else if (item.name == "SO (Revenue)") {
            soBulan = val;
          } else if (item.name == "SM (Revenue)") {
            smBulan = val;
          } else if (item.name == "Total (Revenue)") {
            totalBulan = val;
          } else if (item.name == "Booking (Quantity)") {
            bookingBulan = val;
          }
        }
      } else if (card.title == "INPUT DATA TAHUN SEBELUMNYA") {
        for (var item in card.items) {
          final val =
              int.tryParse(item.controller.text.replaceAll('.', '')) ?? 0;
          if (item.name == "SIU (Units)") {
            siuTahun = val;
          } else if (item.name == "Jasa (Revenue)") {
            jasaTahun = val;
          } else if (item.name == "Oil (Revenue)") {
            oilTahun = val;
          } else if (item.name == "Part (Revenue)") {
            partTahun = val;
          } else if (item.name == "SO (Revenue)") {
            soTahun = val;
          } else if (item.name == "SM (Revenue)") {
            smTahun = val;
          } else if (item.name == "Total (Revenue)") {
            totalTahun = val;
          } else if (item.name == "Booking (Quantity)") {
            bookingTahun = val;
          }
        }
      }
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return showDialog<bool>(
      context: context,
      builder: (context) {
        bool isChecked = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: const Color(0xff0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 650),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Confirm Target Benchmarks",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                      // Text(
                      //   "REVIEWING SYSTEM PARAMETERS FOR V8 CORE OPTIMIZATION",
                      //   style: GoogleFonts.plusJakartaSans(
                      //     color: Colors.grey,
                      //     fontSize: 12,
                      //   ),
                      // ),
                      const SizedBox(height: 24),
                      // WORKING DAYS SECTION
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Informasi Hari Kerja",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "$workingDays HARI",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: Colors.white10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Hari Libur: ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    holidays.isEmpty
                                        ? "Tidak ada hari libur dipilih"
                                        : holidays
                                              .map(
                                                (d) => DateFormat(
                                                  "dd MMM",
                                                ).format(d),
                                              )
                                              .join(", "),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "CURRENT INPUT SUMMARY",
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xff00f2ff),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _summaryCard("SIU TARGET", siu.toString()),
                          _summaryCard("JASA", currencyFormatter.format(jasa)),
                          _summaryCard("OIL", currencyFormatter.format(oil)),
                          _summaryCard(
                            "SPARE PART",
                            currencyFormatter.format(part),
                          ),
                          _summaryCard("S/ORDER", currencyFormatter.format(so)),
                          _summaryCard(
                            "S/MATERIAL",
                            currencyFormatter.format(sm),
                          ),
                          _summaryCard("CS TARGET", targetCSController.text),
                          _summaryCard(
                            "TOTAL PENJUALAN (Rp)",
                            currencyFormatter.format(total),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // MaterialBarChart(
                      //   style: BarChartStyle(
                      //     backgroundColor: Colors.transparent,
                      //   ),
                      //   data: [
                      //     BarChartData(value: total.toDouble(), label: "Total"),
                      //     BarChartData(
                      //       value: targetCS.toDouble(),
                      //       label: "Target CS",
                      //     ),
                      //   ],
                      //   width: 300,
                      //   height: 150,
                      // ),
                      const SizedBox(height: 32),
                      // CHECKBOX SECTION
                      Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (v) {
                              setModalState(() {
                                isChecked = v ?? false;
                              });
                            },
                            side: const BorderSide(color: Colors.white54),
                            activeColor: const Color(0xff00f2ff),
                            checkColor: Colors.black,
                          ),
                          const Expanded(
                            child: Text(
                              "Saya mengkonfirmasi bahwa data target yang diisi sudah benar dan saya memahami bahwa data tidak dapat diubah kembali setelah disimpan.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              "Batal",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isChecked
                                  ? const Color(0xff00f2ff)
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: isChecked
                                ? () => Navigator.pop(context, true)
                                : null,
                            child: Text(
                              "Simpan Sekarang",
                              style: TextStyle(
                                color: isChecked ? Colors.black : Colors.white60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _summaryCard(String title, String value) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMultiDatePicker() async {
    // Buat salinan lokal agar perubahan di dialog tidak langsung
    // men-trigger rebuild _TargetState (yang bisa menghapus nilai Target CS)
    final List<DateTime> tempHolidays = List.from(selectedHolidays);

    await showDialog(
      context: context,
      builder: (context) {
        DateTime focusedDay = DateTime.now();

        return Dialog(
          backgroundColor: const Color(0xff1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SizedBox(
                width: 380,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TableCalendar(
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2030),
                        focusedDay: focusedDay,

                        availableGestures: AvailableGestures.none,

                        /// Disable Minggu
                        enabledDayPredicate: (day) =>
                            day.weekday != DateTime.sunday,

                        /// Multi select — pakai tempHolidays (lokal dialog)
                        selectedDayPredicate: (day) {
                          return tempHolidays.any(
                            (d) =>
                                d.year == day.year &&
                                d.month == day.month &&
                                d.day == day.day,
                          );
                        },

                        onDaySelected: (selectedDay, _) {
                          final normalized = DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                          );

                          // Hanya rebuild dialog, TIDAK rebuild _TargetState
                          setModalState(() {
                            final index = tempHolidays.indexWhere(
                              (d) =>
                                  d.year == normalized.year &&
                                  d.month == normalized.month &&
                                  d.day == normalized.day,
                            );

                            if (index >= 0) {
                              tempHolidays.removeAt(index);
                            } else {
                              tempHolidays.add(normalized);
                            }
                          });
                          // ✅ Tidak ada setState() di sini — Target CS aman
                        },

                        /// 🎨 STYLE SECTION
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          weekendTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          disabledTextStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),

                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.white),
                          weekendStyle: TextStyle(color: Colors.white),
                        ),

                        headerStyle: const HeaderStyle(
                          leftChevronVisible: false,
                          rightChevronVisible: false,
                          titleTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          formatButtonVisible: false,
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    // Dialog sudah ditutup → apply perubahan ke state SEKALIGUS
    // sehingga hanya 1x rebuild, bukan setiap klik hari
    setState(() {
      selectedHolidays = tempHolidays;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final workingDays = countWorkingDays(
      year: now.year,
      month: now.month,
      holidays: selectedHolidays,
    );

    final holidays = selectedHolidays
        .map((d) => "${d.year}-${d.month}-${d.day}")
        .toList();

    // Watch existing target data
    final existingTarget = ref.watch(existingTargetProvider);

    // Populate fields once when data is available
    existingTarget.whenData((data) {
      if (data != null && !_dataLoaded) {
        _dataLoaded = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _populateFields(data);
          setState(() {
            _isEditMode = true;
          });
        });
      }
    });

    final mekanikAsync = ref.watch(mekanikProvider);
    final saAsync = ref.watch(SAProvider);
    final leaderAsync = ref.watch(LeaderProvider);
    final csAsync = ref.watch(CSProvider);
    final productivityAsync = ref.watch(productivityProvider);
    final targetMekanikAsync = ref.watch(targetProvider);

    Widget mekanikSection(AsyncValue<List<alluser>> data) {
      return data.when(
        data: (names) {
          final model = PersonModel(
            title: "Mechanics",
            icon: "assets/Icon (2).png",
            items: names.map((e) => PesonItem(name: e.name)).toList(),
          );

          return _addperson(model);
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text("Error: $e"),
      );
    }

    Widget saSection(AsyncValue<List<alluser>> data) {
      return data.when(
        data: (names) {
          final model = PersonModel(
            title: "Service Advisors",
            icon: "assets/Icon (1).png",
            items: names.map((e) => PesonItem(name: e.name)).toList(),
          );

          return _addperson(model);
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text("Error: $e"),
      );
    }

    Widget leaderSection(AsyncValue<List<alluser>> data) {
      return data.when(
        data: (names) {
          final model = PersonModel(
            title: "Leader",
            icon: "assets/Icon (1).png",
            items: names.map((e) => PesonItem(name: e.name)).toList(),
          );

          return _addperson(model);
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text("Error: $e"),
      );
    }

    Widget csSection(AsyncValue<List<alluser>> data) {
      return data.when(
        data: (names) {
          final model = PersonModel(
            title: "CS Service",
            icon: "assets/Icon (1).png",
            items: names.map((e) => PesonItem(name: e.name)).toList(),
          );

          return _addperson(model);
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text("Error: $e"),
      );
    }

    final date = DateTime.now();

    return Obx(() {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.primary,
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    CardCustume(
                      width: double.infinity,
                      widget: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Textmessage(message: "JUMLAH HARI KERJA"),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: _openMultiDatePicker,
                                child: _itemList(workingDays.toString()),
                              ),
                            ],
                          ),
                          SizedBox(width: 28),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Textmessage(message: "TARGET CS"),

                              const SizedBox(height: 20),
                              Card(
                                color: const Color(0xff0F172A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    width: 1,
                                    color: AppColors.kuningborder,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: targetCSController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      cursorColor: Color(0xffFFC107),
                                      style: TextStyle(
                                        color: Color(0xffFFC107),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            spacing: 20,
                            children: [
                              Textmessage(message: "TARGET PERIOD"),
                              textBold(
                                message: DateFormat(
                                  "MMMM yyyy",
                                ).format(date).toUpperCase(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      padding: 20,
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 22,
                      runSpacing: 22,
                      children: cards.map((e) => _card(e)).toList(),
                    ),
                    SizedBox(height: 30),

                    // Wrap(
                    //   spacing: 22,
                    //   runSpacing: 22,
                    //   children: person.map((e) => _addperson(e)).toList(),
                    // ),
                    // Hide person lists when in edit mode (target already exists)
                    if (!_isEditMode)
                      Wrap(
                        spacing: 22,
                        runSpacing: 22,
                        children: [
                          saSection(saAsync),
                          mekanikSection(mekanikAsync),
                          leaderSection(leaderAsync),
                          csSection(csAsync),
                        ],
                      ),
                    SizedBox(height: 90),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterDocked,
            floatingActionButton: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff1E293B),
                // borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsetsDirectional.all(10),
              child: Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // if (true)
                  if (!_isEditMode)
                    // ButtonCustome(
                    //   ontap: _resetAllFields,
                    //   text: "Clear",
                    //   textColor: Colors.white,
                    //   isIcon: false,
                    //   // color: Colors.blue,
                    // ),
                    ButtonCustome(
                      ontap: () async {
                        final dashboardAsync = ref.read(dashboardProvider);
                        final bulanSebelumAsync = ref.read(
                          databulansebelumProvider,
                        );
                        final tahunSebelumAsync = ref.read(
                          datatahunsebelumProvider,
                        );
                        final totalDays = ref.read(totalWorkingDayProvider);
                        final workingDay = ref.read(workingDayProvider);
                        final remainingDays = ref.read(
                          remainingWorkingDayProvider,
                        );

                        // Ensure data is loaded
                        if (dashboardAsync.hasValue &&
                            bulanSebelumAsync.hasValue &&
                            tahunSebelumAsync.hasValue) {
                          isloading.value = true;
                          try {
                            final success =
                                await ExportService().exportRekapDashboard(
                              dataBulanSebelum: bulanSebelumAsync.value!,
                              dataTahunSebelum: tahunSebelumAsync.value!,
                              mekanikUsers: mekanikAsync.value ?? [],
                              leaderUsers: leaderAsync.value ?? [],
                              saUsers: saAsync.value ?? [],
                              csUsers: csAsync.value ?? [],
                            );
                            if (success) {
                              setState(() {
                                _hasDownloadedExcel = true;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Export berhasil. Anda sekarang dapat menyimpan target."),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Export failed: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            isloading.value = false;
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Data belum siap untuk diexport"),
                            ),
                          );
                        }
                      },
                      text: "Export",
                      textColor: Colors.white,
                      isIcon: true,
                      icon: Icons.download_for_offline,
                      color: Colors.green.withOpacity(0.8),
                    ),
                  Obx(() {
                    return ButtonCustome(
                      ontap: (isloading.value || _isEditMode)
                          ? null
                          : () async {
                              final now = DateTime.now();
                              int prevYear = now.year;
                              int prevMonth = now.month - 1;
                              if (prevMonth == 0) {
                                prevMonth = 12;
                                prevYear -= 1;
                              }
                              final String prevDocId =
                                  "$prevYear-${prevMonth.toString().padLeft(2, '0')}";

                              bool hasPreviousData = await ref
                                  .read(targetRepositoryProvider)
                                  .targetExists(prevDocId);

                              if (hasPreviousData && !_hasDownloadedExcel) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Anda harus download Excel bulan kemarin (Export) terlebih dahulu sebelum bisa publish target.",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }

                              final confirm = await _showSummaryDialog(
                                workingDays: workingDays,
                                holidays: selectedHolidays,
                                targetCS:
                                    int.tryParse(targetCSController.text) ?? 0,
                              );

                              if (confirm != true) return;

                              // Validation: Ensure roles are not empty
                              final mekanikList = mekanikAsync.value ?? [];
                              final saList = saAsync.value ?? [];
                              final leaderList = leaderAsync.value ?? [];
                              final csList = csAsync.value ?? [];

                              if (mekanikList.isEmpty ||
                                  saList.isEmpty ||
                                  leaderList.isEmpty ||
                                  csList.isEmpty) {
                                List<String> missingRoles = [];
                                if (mekanikList.isEmpty)
                                  missingRoles.add("Mekanik");
                                if (saList.isEmpty) missingRoles.add("SA");
                                if (leaderList.isEmpty)
                                  missingRoles.add("Leader");
                                if (csList.isEmpty) missingRoles.add("CS");

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Gagal: Pengguna dengan role ${missingRoles.join(', ')} belum tersedia.",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }

                              isloading.value = true;

                              try {
                                final targetCS =
                                    int.tryParse(targetCSController.text) ?? 0;

                                await saveAllTargets(
                                  ref,
                                  cards,
                                  targetCS,
                                  workingDays,
                                  holidays,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _isEditMode
                                            ? "Target berhasil diupdate"
                                            : "Data berhasil disimpan",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }

                                if (_isEditMode) {
                                  // Refresh provider to reload latest data
                                  ref.invalidate(existingTargetProvider);
                                } else {
                                  // After first publish, switch to edit mode
                                  _resetAllFields();
                                  _dataLoaded = false;
                                  ref.invalidate(existingTargetProvider);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Gagal menyimpan data: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                isloading.value = false;
                              }
                            },
                      text: isloading.value
                          ? (_isEditMode ? "Locked" : "Publishing...")
                          : (_isEditMode ? "Target Locked" : "Publish Target"),
                      color: _isEditMode
                          ? Colors.grey.withOpacity(0.5)
                          : Color(0xff00f2ff),
                      icon: isloading.value
                          ? null
                          : (_isEditMode
                                ? Icons.lock_outline
                                : Icons.save_outlined),
                      isIcon: !isloading.value,
                    );
                  }),
                ],
              ),
            ),
          ),
          if (isloading.value || existingTarget.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    });
  }
}

Widget _card(TargetCardModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(data.icon, width: 20),
          const SizedBox(width: 12),
          Texttitle(message: data.title),
        ],
      ),

      const SizedBox(height: 20),

      Container(
        width: 400,
        decoration: BoxDecoration(
          color: const Color(0xff1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(children: data.items.map((item) => _list(item)).toList()),
      ),
    ],
  );
}

Widget _list(TargetItem item) {
  final bool isPercent = item.ispercentage;
  final bool isCurrency = item.iscurrency;
  final bool isDecimal = item.isdecimal;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            item.name,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xff94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          flex: 3,
          child: _currencyField(
            item.controller,
            isCurrency,
            isPercent,
            isDecimal,
          ),
        ),
      ],
    ),
  );
}

Widget _currencyField(
  TextEditingController controller,
  bool isCurrency,
  bool isPercent,
  bool isDecimal,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: const Color(0xff0F172A),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            /// prefix currency
            if (isCurrency) ...[
              Text(
                "Rp",
                style: GoogleFonts.inter(
                  color: const Color(0xff94A3B8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
            ],

            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  if (isPercent || isDecimal)
                    DecimalInputFormatter() // ✅ khusus persen / decimal
                  else if (isCurrency)
                    CurrencyInputFormatter() // ✅ tetap integer
                  else
                    FilteringTextInputFormatter.digitsOnly,
                ],
                style: GoogleFonts.inter(
                  color: const Color(0xffEAB308),
                  fontSize: 16,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),

            /// suffix percent
            if (isPercent)
              Text(
                "%",
                style: GoogleFonts.inter(color: const Color(0xff94A3B8)),
              ),
          ],
        ),
      ),
    ],
  );
}

Widget _itemList(String title) {
  return Card(
    color: Color(0xff0F172A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(8),
      side: BorderSide(width: 1, color: AppColors.kuningborder),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        spacing: 80,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.kuningborder,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Textmessage(message: "Days"),
        ],
      ),
    ),
  );
}

Widget _addperson(PersonModel data) {
  return CardCustume(
    width: 400,
    padding: 10,
    widget: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xff94A3B8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// LIST PERSON
        Column(
          children: List.generate(data.items.length, (index) {
            final item = data.items[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                color: const Color(0xffFFFFFF).withOpacity(.03),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Textmessage(
                        message: (index + 1).toString().padLeft(2, '0'),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        item.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xff94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // const Spacer(),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.close),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    ),
  );
}
