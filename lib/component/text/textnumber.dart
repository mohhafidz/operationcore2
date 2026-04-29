import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class textNumber extends StatelessWidget {
  const textNumber({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 30,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
    );
  }
}
