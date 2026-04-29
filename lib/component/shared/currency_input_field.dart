import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Formatter currency: angka diformat dengan titik (1.000.000)
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final number = int.tryParse(digits) ?? 0;
    final formatted = _formatWithDots(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithDots(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }

    return buffer.toString().split('').reversed.join();
  }
}

/// Input field currency/angka yang dapat digunakan di SAperformance
/// maupun di fitur/halaman lain yang memerlukan input angka
class CurrencyInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isCurrency;
  final bool readOnly;
  final double width;

  const CurrencyInputField({
    super.key,
    required this.label,
    required this.controller,
    this.isCurrency = true,
    this.readOnly = false,
    this.width = 440,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: readOnly ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xff94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width,
            decoration: BoxDecoration(
              color: const Color(0xff0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (isCurrency) ...[
                  Text(
                    "Rp",
                    style: GoogleFonts.inter(
                      color: const Color(0xff94A3B8),
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    keyboardType: TextInputType.number,
                    inputFormatters: isCurrency
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            CurrencyInputFormatter(),
                          ]
                        : [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.inter(
                      color: const Color(0xffEAB308),
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Input number besar dengan tampilan khusus (untuk unit entry, hari kerja)
class NumberDisplayField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final double width;
  final double fontSize;
  final Color valueColor;

  const NumberDisplayField({
    super.key,
    required this.controller,
    this.enabled = false,
    this.width = 70,
    this.fontSize = 32,
    this.valueColor = const Color(0xffFFC107),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xff1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: TextField(
        enabled: enabled,
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          color: valueColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
