import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Label kecil abu-abu (sub-label, hint)
class AppTextLabel extends StatelessWidget {
  final String text;
  final double fontSize;

  const AppTextLabel(this.text, {super.key, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xff94A3B8),
        fontSize: fontSize,
      ),
    );
  }
}

/// Text judul section / card (putih, bold)
class AppTextTitle extends StatelessWidget {
  final String text;
  final double fontSize;

  const AppTextTitle(this.text, {super.key, this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Text hint / keterangan kecil (gelap)
class AppTextHint extends StatelessWidget {
  final String text;
  final double fontSize;

  const AppTextHint(this.text, {super.key, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xff64748B),
        fontSize: fontSize,
      ),
    );
  }
}

/// Text dengan warna kustom, ukuran, dan berat kustom
class AppText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const AppText(
    this.text, {
    super.key,
    this.color = Colors.white,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}

/// Text gradien untuk judul besar (misal: hari/tanggal)
class AppTextGradient extends StatelessWidget {
  final String text;
  final double fontSize;
  final List<Color> colors;

  const AppTextGradient(
    this.text, {
    super.key,
    this.fontSize = 48,
    this.colors = const [Color(0xffFFFFFF), Color(0xff94A3B8)],
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        foreground: Paint()
          ..shader = LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    );
  }
}
