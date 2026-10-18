import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StockTradingInputFormatter extends TextInputFormatter {
  final String suffix;
  final double threshold;

  StockTradingInputFormatter({
    this.suffix = '₮',
    this.threshold = 1000.0,
  });

  static String format(String value, {String suffix = '₮', double threshold = 1000.0}) {
    if (value.isEmpty) return '';
    String cleanText = value.replaceAll(suffix, '').replaceAll(',', '');
    if (cleanText.isEmpty) return '';

    final number = double.tryParse(cleanText);
    if (number == null) return cleanText + suffix;

    final parts = cleanText.split('.');
    final wholePart = int.tryParse(parts[0]) ?? 0;
    final formattedWhole = NumberFormat('#,###').format(wholePart);

    if (number > threshold) {
      return '$formattedWhole$suffix';
    }

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
    String cleanText = newValue.text.replaceAll(suffix, '').replaceAll(',', '');

    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Handle leading zero if followed by digits
    if (cleanText.length > 1 && cleanText.startsWith('0') && cleanText[1] != '.') {
      cleanText = cleanText.substring(1);
    }

    final number = double.tryParse(cleanText);
    if (number == null) return oldValue;

    // Check threshold: omit decimals if higher than 1000
    bool shouldOmitDecimals = number > threshold;

    if (shouldOmitDecimals && cleanText.contains('.')) {
      cleanText = cleanText.split('.')[0];
    }

    if (cleanText.endsWith('.')) {
      if (shouldOmitDecimals) {
        // If threshold exceeded, don't allow trailing dot
        String formatted = NumberFormat('#,###').format(number.toInt());
        String newText = '$formatted$suffix';
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length - suffix.length),
        );
      } else {
        final partBeforeDot = cleanText.substring(0, cleanText.length - 1);
        final whole = int.tryParse(partBeforeDot.isEmpty ? '0' : partBeforeDot);
        if (whole == null) return oldValue;
        String formatted = NumberFormat('#,###').format(whole);
        String newText = '$formatted.$suffix';
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length - suffix.length),
        );
      }
    }

    final parts = cleanText.split('.');
    if (parts.length > 2) return oldValue;

    final wholePartStr = parts[0];
    final wholeNumber = int.tryParse(wholePartStr.isEmpty ? '0' : wholePartStr);
    if (wholeNumber == null) return oldValue;

    String formattedWhole = NumberFormat('#,###').format(wholeNumber);
    String newFormattedText;

    if (parts.length > 1 && !shouldOmitDecimals) {
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
