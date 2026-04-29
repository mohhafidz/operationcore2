import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class textNumber2 extends StatelessWidget {
  const textNumber2({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        color: Color(0xff94A3B8),
      ),
    );
  }
}
