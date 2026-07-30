import 'package:flutter/services.dart';

class CurrencySuffixFormatter extends TextInputFormatter {
  final String suffix;

  CurrencySuffixFormatter({this.suffix = '₮'});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 1. Remove suffix if present to get pure user input
    String cleanText = newValue.text.replaceAll(suffix, '');

    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // 2. Attach suffix with ZERO space
    String newFormattedText = '$cleanText$suffix';

    // 3. Keep cursor before the suffix symbol
    int selectionIndex = newValue.selection.end;
    if (selectionIndex > cleanText.length) {
      selectionIndex = cleanText.length;
    }

    return TextEditingValue(
      text: newFormattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}