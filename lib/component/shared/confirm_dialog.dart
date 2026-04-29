import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog konfirmasi standar yang dapat digunakan di seluruh aplikasi
/// Mengembalikan [bool] true jika user menekan tombol konfirmasi, false jika batal
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = "Simpan",
    this.cancelLabel = "Batal",
    this.confirmColor = const Color(0xff06B6D4),
  });

  /// Helper statis untuk menampilkan dialog dengan mudah
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = "Simpan",
    String cancelLabel = "Batal",
    Color confirmColor = const Color(0xff06B6D4),
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: GoogleFonts.inter(color: const Color(0xff94A3B8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelLabel,
            style: GoogleFonts.inter(color: const Color(0xff94A3B8)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
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
