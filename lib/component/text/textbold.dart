import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class textBold extends StatelessWidget {
  const textBold({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
