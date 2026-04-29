import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// int parseSafeInt(String value) {
//   return int.tryParse(value.trim().replaceAll(',', '')) ?? 0;
// }

final numberFormatter = NumberFormat('#,###', 'en_US');
final decimalFormatter = NumberFormat('#,##0.00', 'en_US');

String formatDecimal(num value) {
  return decimalFormatter.format(value);
}

// import 'package:intl/intl.dart';

// final numberFormatter = NumberFormat('#,##0.##', 'en_US');

String formatValue(String value) {
  final clean = value.trim();

  // 1️⃣ Handle persen
  if (clean.contains('%')) {
    final percentValue = double.tryParse(
      clean.replaceAll('%', '').replaceAll(',', ''),
    );

    if (percentValue == null) return clean;

    return "$percentValue%";
  }

  // 2️⃣ Handle angka biasa (int / double / negatif)
  final numericValue = double.tryParse(clean.replaceAll(',', ''));

  if (numericValue == null) return clean;

  return numberFormatter.format(numericValue);
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hapus semua selain angka
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = int.parse(digitsOnly);
    final newText = _formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');

    // hanya allow angka + 1 titik + max 2 decimal
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(text)) {
      return oldValue;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
