import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget untuk menampilkan avatar dan nama SA
class SaAvatar extends StatelessWidget {
  final String name;

  const SaAvatar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: const Color(0xff22C55E),
          ),
          child: Center(
            child: Text(
              "A",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          name,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
