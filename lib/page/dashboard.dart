import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart'; // Sesuaikan nama package jika ada perbedaan kecil
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:operationcore2/page/dashboardoverall.dart';
import 'package:operationcore2/page/target_achievement.dart';
import 'package:operationcore2/providers/dashboard_provider.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _dayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Ambil nilai awal working day dengan aman setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workingDay = ref.read(workingDayProvider);
      _dayController.text = workingDay.toString();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan state jika diubah dari widget lain
    ref.listen<int>(workingDayProvider, (previous, next) {
      if (next.toString() != _dayController.text) {
        _dayController.text = next.toString();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat("dd MMM yyyy").format(DateTime.now()).toUpperCase(),

          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF0F172A), // Background gelap premium
      body: BottomBar(
        // 1. Konfigurasi Tata Letak (Layout)
        layout: BottomBarLayout(
          width: MediaQuery.of(context).size.width * 0.4,
          borderRadius: BorderRadius.circular(500),
          fit: StackFit.expand,
          clip: Clip.none,
        ),
        // 2. Efek Gerakan & Animasi (Motion)
        motion: const BottomBarMotion.cupertino(
          preset: BottomBarCupertinoMotion.snappy,
          duration: Duration(milliseconds: 460),
          slideStart: Offset(0, 3),
        ),
        // 3. Kontrol Perilaku Scroll (Sembunyi otomatis saat di-scroll)
        scrollBehavior: const BottomBarScrollBehavior(hideOnScroll: false),
        // 4. Dekorasi dan Warna (Theme)
        theme: BottomBarThemeData(
          barDecoration: BoxDecoration(
            color: const Color(
              0xFF1E293B,
            ), // Warna Slate gelap serasi dengan dashboard Anda
            borderRadius: BorderRadius.circular(500),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        // 5. Body pembungkus halaman dashboard Anda
        body: TabBarView(
          controller: _tabController,
          physics:
              const NeverScrollableScrollPhysics(), // Mematikan swipe horizontal agar tidak bentrok dengan gauge
          children: [
            DashboardOverall(dayController: _dayController),
            TargetAchievement(),
          ],
        ),
        // 6. Tampilan Navigasi di dalam Bottom Bar
        child: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF38BDF8),
          labelColor: const Color(0xFF38BDF8),
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: "Overall"),
            Tab(icon: Icon(Icons.analytics_rounded), text: "Detail"),
          ],
        ),
      ),
    );
  }
}
