import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonCustome extends StatelessWidget {
  const ButtonCustome({
    super.key,
    this.icon,
    this.isIcon,
    required this.text,
    this.color,
    this.textColor,
    this.ontap,
  });
  final bool? isIcon;
  final IconData? icon;
  final String text;
  final Color? color;
  final Color? textColor;
  final VoidCallback? ontap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? const Color(0xff0a0e14),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          // spacing: ,
          children: [
            if (isIcon! && icon != null) ...[
              Icon(icon, color: Colors.black),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: GoogleFonts.inter(color: textColor ?? Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
