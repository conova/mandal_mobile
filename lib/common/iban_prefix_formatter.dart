import 'package:flutter/services.dart';

/// IBAN-ий "MN" угтварыг хамгаална — хэрэглэгч устгах/өөрчлөх боломжгүй.
class IbanPrefixFormatter extends TextInputFormatter {
  static const String prefix = 'MN';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(prefix)) return newValue;
    // Угтвар эвдэрсэн — үлдсэн хэсгийг хадгалж "MN"-г сэргээнэ
    var body = newValue.text;
    if (body.startsWith('M')) body = body.substring(1);
    if (body.startsWith('N')) body = body.substring(1);
    final text = '$prefix$body';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
