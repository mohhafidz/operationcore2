import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operationcore2/component/appcolor.dart';
import 'package:operationcore2/component/shared/app_text.dart';
import 'package:operationcore2/component/shared/confirm_dialog.dart';
import 'package:operationcore2/component/shared/currency_input_field.dart';
import 'package:operationcore2/component/shared/performance_card.dart';
import 'package:operationcore2/component/dashboard/working_day_card.dart';
import 'package:operationcore2/providers/auth_provider.dart';
import 'package:operationcore2/providers/saperformanceprovider.dart';

class SAperformance extends ConsumerStatefulWidget {
  const SAperformance({super.key});

  @override
  ConsumerState<SAperformance> createState() => _SAperformanceState();
}

class _SAperformanceState extends ConsumerState<SAperformance> {
  final TextEditingController lc = TextEditingController();
  final TextEditingController oil = TextEditingController();
  final TextEditingController spart = TextEditingController();
  final TextEditingController so = TextEditingController();
  final TextEditingController sm = TextEditingController();

  final TextEditingController oilCost = TextEditingController();
  final TextEditingController soCost = TextEditingController();
  final TextEditingController spartCost = TextEditingController();
  final TextEditingController smCost = TextEditingController();
  final TextEditingController offset = TextEditingController();

  final TextEditingController unitEntry = TextEditingController(text: "0");
  final TextEditingController booking = TextEditingController();
  final TextEditingController pdi = TextEditingController();

  bool _alreadySubmitted = false;
  bool _isLoadingInitial = true;
  Map<String, dynamic>? _originalSaDetail;
  Map<String, int>? _originalTracking;

  List<TextEditingController> get _allControllers => [
    lc,
    oil,
    spart,
    so,
    sm,
    oilCost,
    soCost,
    spartCost,
    smCost,
    unitEntry,
    booking,
    pdi,
    offset,
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in _allControllers) {
      controller.addListener(_rebuild);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  Future<void> _loadExistingData() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      if (mounted) setState(() => _isLoadingInitial = false);
      return;
    }

    try {
      final repo = ref.read(saPerformanceRepositoryProvider);
      final saDetail = await repo.getTodaySaDetail(user.id);
      final tracking = await repo.getTodayServiceTracking();

      if (!mounted) return;

      if (saDetail != null) {
        _originalSaDetail = saDetail;
        final penjualanData =
            saDetail['penjualan'] as Map<String, dynamic>? ?? {};
        final hppData = saDetail['hpp'] as Map<String, dynamic>? ?? {};

        unitEntry.text = (saDetail['unitEntry'] ?? 0).toString();
        lc.text = (penjualanData['lc'] ?? 0).toString();
        so.text = (penjualanData['sOrder'] ?? 0).toString();
        oil.text = (penjualanData['oil'] ?? 0).toString();
        sm.text = (penjualanData['sMaterial'] ?? 0).toString();
        spart.text = (penjualanData['sPart'] ?? 0).toString();

        oilCost.text = (hppData['oil'] ?? 0).toString();
        soCost.text = (hppData['sOrder'] ?? 0).toString();
        spartCost.text = (hppData['sPart'] ?? 0).toString();
        smCost.text = (hppData['sMaterial'] ?? 0).toString();
        offset.text = (hppData['offset'] ?? 0).toString();

        _alreadySubmitted = true;
      }

      if (tracking != null) {
        _originalTracking = tracking;
        booking.text = (tracking['booking'] ?? 0).toString();
        pdi.text = (tracking['pdi'] ?? 0).toString();
      }
    } catch (_) {
      // If loading fails, allow fresh input
    }

    if (mounted) setState(() => _isLoadingInitial = false);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  int _parseNumber(TextEditingController controller) {
    final raw = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return buffer.toString().split('').reversed.join();
  }

  int get totalPenjualan =>
      _parseNumber(lc) +
      _parseNumber(so) +
      _parseNumber(oil) +
      _parseNumber(sm) +
      _parseNumber(spart);

  int get totalHpp =>
      _parseNumber(oilCost) +
      _parseNumber(soCost) +
      _parseNumber(spartCost) +
      _parseNumber(smCost);

  Future<void> _saveData() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: "Konfirmasi",
      message: "Yakin ingin menyimpan data SA Performance ini?",
      confirmLabel: _alreadySubmitted ? "Update" : "Simpan",
      confirmColor: _alreadySubmitted
          ? const Color(0xffEAB308)
          : const Color(0xff06B6D4),
    );

    if (!confirm) return;

    final saveNotifier = ref.read(saPerformanceSaveProvider.notifier);
    final user = ref.read(authProvider).user;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User belum login")));
      return;
    }

    final penjualan = {
      'lc': _parseNumber(lc),
      'sOrder': _parseNumber(so),
      'oil': _parseNumber(oil),
      'sMaterial': _parseNumber(sm),
      'sPart': _parseNumber(spart),
      'total': totalPenjualan,
    };

    final hpp = {
      'oil': _parseNumber(oilCost),
      'sOrder': _parseNumber(soCost),
      'sPart': _parseNumber(spartCost),
      'sMaterial': _parseNumber(smCost),
      'offset': _parseNumber(offset),
      'total': totalHpp,
    };

    final serviceTracking = {
      'booking': _parseNumber(booking),
      'pdi': _parseNumber(pdi),
    };

    await saveNotifier.save(
      saId: user.id,
      saName: user.name,
      unitEntry: _parseNumber(unitEntry),
      penjualan: penjualan,
      hpp: hpp,
      serviceTracking: serviceTracking,
      oldData: _originalSaDetail,
      oldBooking: _originalTracking?['booking'],
    );

    final saveState = ref.read(saPerformanceSaveProvider);

    if (saveState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data: ${saveState.error}")),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));

    await _loadExistingData();
  }

  Future<void> _saveServiceTrackingOnly() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: "Konfirmasi",
      message: "Yakin ingin memperbarui data Service Tracking?",
      confirmLabel: "Update",
    );

    if (!confirm) return;

    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User belum login")));
      return;
    }

    final serviceTracking = {
      'booking': _parseNumber(booking),
      'pdi': _parseNumber(pdi),
    };

    final saveNotifier = ref.read(saPerformanceSaveProvider.notifier);
    await saveNotifier.saveServiceTrackingOnly(
      saName: user.name,
      serviceTracking: serviceTracking,
    );

    final saveState = ref.read(saPerformanceSaveProvider);
    if (saveState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memperbarui data: ${saveState.error}"),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Service Tracking berhasil diperbarui"),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _allControllers) {
      controller.removeListener(_rebuild);
      controller.dispose();
    }
    super.dispose();
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final dayNumber = now.day;

    String suffix = "th";
    if (dayNumber % 10 == 1 && dayNumber != 11) {
      suffix = "st";
    } else if (dayNumber % 10 == 2 && dayNumber != 12) {
      suffix = "nd";
    } else if (dayNumber % 10 == 3 && dayNumber != 13) {
      suffix = "rd";
    }

    return "$dayName, $dayNumber$suffix";
  }

  Widget _sectionatas() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              "ENTRY MODE: DAILY",
              color: Color(0xff06B6D4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            AppTextGradient(_getFormattedDate()),
            const AppTextLabel(
              "Recording performance data for Service Advisor",
              fontSize: 16,
            ),
          ],
        ),
        const Spacer(),
        UnitEntryCard(controller: unitEntry),
      ],
    );
  }

  Widget _sectionkiri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_alreadySubmitted)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xff22C55E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xff22C55E).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xff22C55E)),
                const SizedBox(width: 12),
                const AppText(
                  "Data SA Performance hari ini sudah diisi. Anda dapat memperbarui data jika diperlukan.",
                  color: Color(0xff22C55E),
                  fontSize: 13,
                ),
              ],
            ),
          ),

        PerformanceCard(
          title: "PENJUALAN (SALES)",
          icon: Icons.shopping_cart_outlined,
          headerColor: const Color(0xff06B6D4),
          showSubtotal: true,
          subtotalTitle: "SUBTOTAL PENJUALAN",
          subtotalValue: _formatNumber(totalPenjualan),
          subtotalColor: const Color(0xff06B6D4),
          fields: [
            CurrencyInputField(
              label: "L/C (LABOUR CHARGE)",
              controller: lc,
              isCurrency: true,
            ),
            CurrencyInputField(
              label: "S/ORDER",
              controller: so,
              isCurrency: true,
            ),
            CurrencyInputField(
              label: "OIL",
              controller: oil,
              isCurrency: true,
            ),
            CurrencyInputField(
              label: "S/MATERIAL",
              controller: sm,
              isCurrency: true,
            ),
            CurrencyInputField(
              label: "S/PART",
              controller: spart,
              isCurrency: true,
            ),
          ],
        ),

        const SizedBox(height: 30),

        PerformanceCard(
          title: "HPP (COSTS)",
          icon: Icons.inventory_2_outlined,
          headerColor: const Color(0xffEAB308),
          showSubtotal: true,
          subtotalTitle: "SUBTOTAL HPP",
          subtotalValue: _formatNumber(totalHpp),
          subtotalColor: const Color(0xffEAB308),
          fields: [
            CurrencyInputField(
              label: "OFFSET",
              controller: offset,
              isCurrency: true,
            ),
            CurrencyInputField(
              label: "OIL",
              controller: oilCost,
              isCurrency: true,
            ),
            CurrencyInputField(
              label: "S/ORDER",
              controller: soCost,
              isCurrency: true,
            ),
            CurrencyInputField(
              label: "S/PART",
              controller: spartCost,
              isCurrency: true,
            ),
            CurrencyInputField(
              label: "S/MATERIAL",
              controller: smCost,
              isCurrency: true,
            ),
          ],
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _sectionkanan() {
    final saveState = ref.watch(saPerformanceSaveProvider);
    final isLoading = saveState.isLoading;

    return Column(
      children: [
        const SizedBox(height: 30),
        PerformanceCard(
          title: "SERVICE TRACKING",
          icon: Icons.sticky_note_2_outlined,
          headerColor: const Color(0xff06B6D4),
          showSubtotal: false,
          subtotalTitle: "",
          subtotalValue: "",
          fields: [
            CurrencyInputField(
              label: "BOOKING",
              controller: booking,
              isCurrency: false,
            ),
            CurrencyInputField(
              label: "PDI",
              controller: pdi,
              isCurrency: false,
            ),
          ],
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _alreadySubmitted
                ? const Color(0xffEAB308)
                : const Color(0xff06B6D4),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isLoading ? null : _saveData,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _alreadySubmitted ? Icons.update : Icons.save,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    AppText(
                      _alreadySubmitted ? "UPDATE PERFORMANCE" : "SAVE ENTRY",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xff06B6D4)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            children: [
              _sectionatas(),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _sectionkiri()),
                  const SizedBox(width: 20),
                  Expanded(flex: 1, child: _sectionkanan()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


