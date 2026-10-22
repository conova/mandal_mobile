import 'dart:math' as math;
import 'package:flutter/services.dart';

class CurrencySuffixFormatter extends TextInputFormatter {
  final String suffix;

  /// 0 = whole numbers only (default). Use 2 if the field should accept decimals.
  final int maxDecimals;

  CurrencySuffixFormatter({this.suffix = '₮', this.maxDecimals = 0});

  static final _groupRegex = RegExp(r'\B(?=(\d{3})+(?!\d))');
  static final _allowedChar = RegExp(r'[0-9.]');

  static String _group(String digits) =>
      digits.replaceAllMapped(_groupRegex, (_) => ',');

  /// For programmatic text (initial value, external updates).
  /// "100000.0" -> "100,000", "98.50" -> "98.5", "98.55" -> "98.55"
  static String format(
      String value, {
        String suffix = '₮',
        int maxDecimals = 2,
      }) {
    if (value.isEmpty) return '';
    final clean = value
        .replaceAll('₮', '')
        .replaceAll('\$', '')
        .replaceAll(suffix, '')
        .replaceAll(',', '');
    if (clean.isEmpty) return '';
    if (double.tryParse(clean) == null) return clean + suffix;

    final parts = clean.split('.');
    final whole = _group(parts[0].isEmpty ? '0' : parts[0]);

    var dec = parts.length > 1 ? parts[1] : '';
    if (dec.length > maxDecimals) dec = dec.substring(0, maxDecimals);
    dec = dec.replaceFirst(RegExp(r'0+$'), ''); // drop trailing zeros

    return dec.isEmpty ? '$whole$suffix' : '$whole.$dec$suffix';
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text;
    var cursor = newValue.selection.baseOffset;
    if (cursor < 0 || cursor > text.length) cursor = text.length;

    // Backspace removed only a thousands separator: delete the digit before it.
    if (text.length == oldValue.text.length - 1 &&
        oldValue.text.contains(',') &&
        oldValue.text.replaceAll(',', '') == text.replaceAll(',', '')) {
      if (cursor > 0) {
        text = text.replaceRange(cursor - 1, cursor, '');
        cursor = cursor - 1;
      }
    }
    // Backspace pressed while the cursor was after the suffix:
    // the suffix got deleted, so delete the last digit instead.
    else if (suffix.isNotEmpty &&
        oldValue.text.endsWith(suffix) &&
        !text.endsWith(suffix) &&
        text.length < oldValue.text.length) {
      text = text.isEmpty ? '' : text.substring(0, text.length - 1);
      cursor = text.length;
    }

    // Keep only digits and dots, counting how many are before the cursor.
    final rawBuf = StringBuffer();
    var cursorRaw = 0;
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (_allowedChar.hasMatch(c)) {
        rawBuf.write(c);
        if (i < cursor) cursorRaw++;
      }
    }
    final raw = rawBuf.toString();
    if (raw.isEmpty) return const TextEditingValue(text: '');

    // Apply decimal rules, tracking the cursor.
    final sb = StringBuffer();
    var newCursor = 0;
    var seenDot = false;
    var decCount = 0;
    for (var i = 0; i < raw.length; i++) {
      final c = raw[i];
      var keep = true;
      if (c == '.') {
        if (maxDecimals == 0 || seenDot) {
          keep = false;
        } else {
          seenDot = true;
        }
      } else if (seenDot) {
        if (decCount >= maxDecimals) {
          keep = false;
        } else {
          decCount++;
        }
      }
      if (keep) {
        sb.write(c);
        if (i < cursorRaw) newCursor++;
      }
    }
    final clean = sb.toString();
    if (clean.isEmpty) return const TextEditingValue(text: '');

    final hasDot = clean.contains('.');
    final whole = hasDot ? clean.substring(0, clean.indexOf('.')) : clean;
    final dec = hasDot ? clean.substring(clean.indexOf('.') + 1) : '';

    // Strip leading zeros ("05" -> "5"), keep a single "0".
    var wholeNorm = whole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (wholeNorm.isEmpty) {
      // ".5" -> "0.5"
      wholeNorm = '0';
      newCursor += 1;
    } else {
      newCursor = math.max(0, newCursor - (whole.length - wholeNorm.length));
    }

    final formatted =
    hasDot ? '${_group(wholeNorm)}.$dec' : _group(wholeNorm);

    // Map "N significant chars before cursor" back into the formatted string.
    var pos = 0;
    if (newCursor > 0) {
      var seen = 0;
      pos = formatted.length;
      for (var i = 0; i < formatted.length; i++) {
        if (formatted[i] != ',') seen++;
        if (seen == newCursor) {
          pos = i + 1;
          break;
        }
      }
    }

    return TextEditingValue(
      text: '$formatted$suffix',
      selection: TextSelection.collapsed(offset: pos), // always before suffix
    );
  }
}