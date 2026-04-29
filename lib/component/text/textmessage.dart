import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Textmessage extends StatelessWidget {
  const Textmessage({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.inter(
        fontSize: 10,
        color: Color(0xff94A3B8),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
