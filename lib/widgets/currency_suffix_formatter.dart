import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencySuffixFormatter extends TextInputFormatter {
  final String suffix;

  CurrencySuffixFormatter({this.suffix = '₮'});

  static String format(String value, {String suffix = '₮'}) {
    if (value.isEmpty) return '';
    // Strip common currency symbols to avoid duplicates like 1,000₮$
    String cleanText = value
        .replaceAll('₮', '')
        .replaceAll('\$', '')
        .replaceAll(suffix, '')
        .replaceAll(',', '');
    if (cleanText.isEmpty) return '';

    final number = double.tryParse(cleanText);
    if (number == null) return cleanText + suffix;

    final parts = cleanText.split('.');
    final wholePart = int.tryParse(parts[0]) ?? 0;
    final formattedWhole = NumberFormat('#,###').format(wholePart);

    if (parts.length > 1) {
      String decimalPart = parts[1];
      if (decimalPart.length > 2) decimalPart = decimalPart.substring(0, 2);
      return '$formattedWhole.$decimalPart$suffix';
    }

    return '$formattedWhole$suffix';
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

    // Handle leading zero if followed by digits
    if (cleanText.length > 1 && cleanText.startsWith('0') && cleanText[1] != '.') {
      cleanText = cleanText.substring(1);
    }

    // Handle dot
    if (cleanText.endsWith('.')) {
      final partBeforeDot = cleanText.substring(0, cleanText.length - 1);
      final number = int.tryParse(partBeforeDot.isEmpty ? '0' : partBeforeDot);
      if (number == null) return oldValue;

      String formatted = NumberFormat('#,###').format(number);
      String newText = '$formatted.$suffix';
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length - suffix.length),
      );
    }
    final parts = cleanText.split('.');
    if (parts.length > 2) return oldValue; // Only one dot allowed

    final wholePartStr = parts[0];
    final wholeNumber = int.tryParse(wholePartStr.isEmpty ? '0' : wholePartStr);
    if (wholeNumber == null) return oldValue;

    String formattedWhole = NumberFormat('#,###').format(wholeNumber);
    String newFormattedText;

    if (parts.length > 1) {
      String decimalPart = parts[1];
      if (decimalPart.length > 2) decimalPart = decimalPart.substring(0, 2);
      newFormattedText = '$formattedWhole.$decimalPart$suffix';
    } else {
      newFormattedText = '$formattedWhole$suffix';
    }
    int selectionIndex = newFormattedText.length - suffix.length;

    return TextEditingValue(
      text: newFormattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
