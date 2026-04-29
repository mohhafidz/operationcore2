import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AutoUpdater {
  // Alamat API GitHub Repository Anda
  static const String githubRepo = "mohHafidz/operationcore2";
  static const String apiUrl =
      "https://api.github.com/repos/$githubRepo/releases/latest";

  /// Fungsi ini dipanggil saat aplikasi (Dashboard/Home) baru terbuka
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final dio = Dio();
      // 1. Cek versi terbaru di GitHub secara diam-diam
      final response = await dio.get(apiUrl);
      if (response.statusCode == 200) {
        final latestVersionTag =
            response.data['tag_name'] as String; // Contoh: "v1.0.1"
        final latestVersion = latestVersionTag.replaceAll('v', '');

        // 2. Baca versi aplikasi yang sedang di-run saat ini
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version; // Contoh: "1.0.0"

        // 3. Bandingkan versinya
        if (_isNewerVersion(latestVersion, currentVersion)) {
          final assets = response.data['assets'] as List;
          if (assets.isNotEmpty) {
            final downloadUrl = assets[0]['browser_download_url'];

            // 4. Jika ada versi baru, tampilkan Pop-up
            if (context.mounted) {
              _showUpdateDialog(context, latestVersion, downloadUrl);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Gagal mengecek update: $e");
    }
  }

  /// Fungsi sederhana membandingkan versi (misal: 1.0.1 vs 1.0.0)
  static bool _isNewerVersion(String latest, String current) {
    List<int> lParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    List<int> cParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    for (int i = 0; i < 3; i++) {
      int l = i < lParts.length ? lParts[i] : 0;
      int c = i < cParts.length ? cParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
    BuildContext context,
    String newVersion,
    String downloadUrl,
  ) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // User tidak bisa klik luar pop-up, harus pilih opsi
      builder: (context) =>
          _UpdateDialogUI(downloadUrl: downloadUrl, newVersion: newVersion),
    );
  }
}

/// Widget Pop-up / Dialog yang akan muncul
class _UpdateDialogUI extends StatefulWidget {
  final String downloadUrl;
  final String newVersion;

  const _UpdateDialogUI({required this.downloadUrl, required this.newVersion});

  @override
  State<_UpdateDialogUI> createState() => _UpdateDialogUIState();
}

class _UpdateDialogUIState extends State<_UpdateDialogUI> {
  bool isDownloading = false;
  double progress = 0.0;

  Future<void> _startDownload() async {
    setState(() {
      isDownloading = true;
    });

    try {
      final dio = Dio();

      // Ambil folder penyimpanan sementara (Temp) Windows
      final tempDir = await getTemporaryDirectory();
      // Simpan installer dengan nama yang spesifik
      final savePath =
          "${tempDir.path}\\OperationCore-Setup-${widget.newVersion}.exe";

      // Mulai download file .exe dari GitHub ke laptop pengguna
      await dio.download(
        widget.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = received / total;
            });
          }
        },
      );

      // SETELAH DOWNLOAD SELESAI:
      // Jalankan Installer .exe nya dalam mode detached
      // Tambahkan flag /VERYSILENT agar proses instalasi berjalan di background (tanpa klik Next-Next)
      await Process.start(savePath, [
        '/VERYSILENT',
      ], mode: ProcessStartMode.detached);
      // Matikan aplikasi Flutter ini secara paksa (agar file lama tidak di-lock saat di-overwrite installer)
      exit(0);
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Download gagal. Silakan coba lagi nanti.",
              style: GoogleFonts.inter(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Update Tersedia",
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: isDownloading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Sedang mengunduh versi terbaru...",
                  style: GoogleFonts.inter(color: const Color(0xff94A3B8)),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white10,
                  color: const Color(0xff06B6D4),
                ),
                const SizedBox(height: 8),
                Text(
                  "${(progress * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Text(
              "Versi baru (${widget.newVersion}) tersedia. Apakah Anda ingin memperbaruinya sekarang?\n\nAplikasi akan menutup secara otomatis untuk instalasi saat download selesai.",
              style: GoogleFonts.inter(color: const Color(0xff94A3B8)),
            ),
      actions: isDownloading
          ? [] // Sembunyikan tombol saat sedang download
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Nanti Saja",
                  style: GoogleFonts.inter(color: const Color(0xff94A3B8)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff06B6D4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _startDownload,
                child: Text(
                  "Update Sekarang",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
    );
  }
}
