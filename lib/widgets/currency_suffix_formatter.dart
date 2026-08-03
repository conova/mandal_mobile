import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencySuffixFormatter extends TextInputFormatter {
  final String suffix;

  CurrencySuffixFormatter({this.suffix = '₮'});

  static String format(String value, {String suffix = '₮'}) {
    String cleanText = value.replaceAll(suffix, '').replaceAll(',', '');
    if (cleanText.isEmpty) return '';

    final number = int.tryParse(cleanText);
    if (number == null) return '';

    final formatter = NumberFormat('#,###');
    return '${formatter.format(number)}$suffix';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Remove suffix and separators to get pure user input
    String cleanText = newValue.text.replaceAll(suffix, '').replaceAll(',', '');

    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // 2. Format with thousand separators
    final number = int.tryParse(cleanText);
    if (number == null) return oldValue;

    final formatter = NumberFormat('#,###');
    String formattedNumber = formatter.format(number);

    // 3. Attach suffix
    String newFormattedText = '$formattedNumber$suffix';

    // 4. Calculate selection index
    // Keep it at the end of the numbers (before suffix).
    int selectionIndex = newFormattedText.length - suffix.length;

    return TextEditingValue(
      text: newFormattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
