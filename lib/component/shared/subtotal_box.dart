import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Box subtotal dengan judul kecil dan nilai besar berwarna
/// Digunakan di SAperformance (subtotal penjualan, subtotal HPP)
class SubtotalBox extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final bool showCurrencyPrefix;

  const SubtotalBox({
    super.key,
    required this.title,
    required this.value,
    required this.valueColor,
    this.showCurrencyPrefix = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xff94A3B8),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            showCurrencyPrefix ? "Rp $value" : value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
