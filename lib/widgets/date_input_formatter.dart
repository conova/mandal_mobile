import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newText = newValue.text;
    final String oldText = oldValue.text;

    // Allow deletion of characters including dots
    if (newText.length < oldText.length) {
      return newValue;
    }

    // Filter only digits
    final digitsOnly = newText.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      final int index = i + 1;
      // Add dot after year (4 digits) and month (2 digits)
      if ((index == 4 || index == 6) && index < digitsOnly.length) {
        buffer.write('.');
      }
    }

    String formatted = buffer.toString();
    
    // Auto-append dot if exactly 4 or 6 digits are typed to prompt next input
    if (digitsOnly.length == 4 && !oldText.endsWith('.')) {
      formatted = '$formatted.';
    } else if (digitsOnly.length == 6 && !oldText.endsWith('.')) {
      formatted = '$formatted.';
    }

    // Limit to YYYY.MM.DD length
    if (formatted.length > 10) {
      formatted = formatted.substring(0, 10);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
