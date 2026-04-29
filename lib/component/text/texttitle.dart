import 'package:flutter/material.dart';
import 'package:operationcore2/component/appcolor.dart';
import 'package:google_fonts/google_fonts.dart';

class Texttitle extends StatelessWidget {
  const Texttitle({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.inter(
        fontSize: 18,
        color: AppColors.white,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
