import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PercentSuffixFormatter extends TextInputFormatter {
  final String suffix;
  final int decimalDigits;

  PercentSuffixFormatter({
    this.suffix = '%',
    this.decimalDigits = 4,
  });

  static String format(dynamic value, {String suffix = '%', int decimalDigits = 4}) {
    if (value == null) return '';

    double? number;
    if (value is num) {
      number = value.toDouble();
    } else if (value is String) {
      String cleanText = value.replaceAll(suffix, '').replaceAll(',', '');
      number = double.tryParse(cleanText);
    }

    if (number == null) return '';

    final formatter = NumberFormat.decimalPattern()
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = decimalDigits;

    return '${formatter.format(number)}$suffix';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Remove suffix and separators
    String cleanText = newValue.text.replaceAll(suffix, '').replaceAll(',', '');

    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Handle multiple dots if any
    if ('.'.allMatches(cleanText).length > 1) {
      return oldValue;
    }

    // 2. Parse number
    final number = double.tryParse(cleanText);
    if (number == null) {
      // If the user is typing a dot at the end, allow it
      if (cleanText.endsWith('.')) {
        return newValue;
      }
      return oldValue;
    }

    // 3. Format
    String formattedNumber;
    
    // Handle the case where the user is typing decimals
    if (cleanText.contains('.')) {
      int dotIndex = cleanText.indexOf('.');
      String decimals = cleanText.substring(dotIndex);
      // Limit decimals
      if (decimals.length > decimalDigits + 1) {
          return oldValue;
      }
      
      String integerPart = cleanText.substring(0, dotIndex);
      String formattedInteger = integerPart.isEmpty 
          ? '0' 
          : NumberFormat('#,###').format(double.parse(integerPart));
      formattedNumber = '$formattedInteger$decimals';
    } else {
      formattedNumber = NumberFormat('#,###').format(number);
    }

    // 4. Attach suffix
    String newFormattedText = '$formattedNumber$suffix';

    // 5. Calculate selection index
    int selectionIndex = newFormattedText.length - suffix.length;
    
    // If the user was editing somewhere in the middle
    if (newValue.selection.baseOffset < newValue.text.length - suffix.length) {
        selectionIndex = newValue.selection.baseOffset;
        
        // Adjust for added/removed commas
        int oldCommas = ','.allMatches(newValue.text).length;
        int newCommas = ','.allMatches(newFormattedText).length;
        selectionIndex += (newCommas - oldCommas);
        
        if (selectionIndex > newFormattedText.length - suffix.length) {
          selectionIndex = newFormattedText.length - suffix.length;
        }
        if (selectionIndex < 0) selectionIndex = 0;
    }

    return TextEditingValue(
      text: newFormattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
