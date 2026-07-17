import 'package:flutter/services.dart';

/// IBAN-ий "MN" угтварыг хамгаална — хэрэглэгч устгах/өөрчлөх боломжгүй.
class IbanPrefixFormatter extends TextInputFormatter {
  static const String prefix = 'MN';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Хэрэв утга хоосон бол "MN" нэмэхгүй
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Угтвар аль хэдийн байвал хэвээр үлдээнэ
    if (newValue.text.startsWith(prefix)) {
      return newValue;
    }

    // Угтвар эвдэрсэн эсвэл байхгүй үед "MN" нэмж засна
    String body = newValue.text;
    if (body.startsWith('M')) {
      body = body.substring(1);
      if (body.startsWith('N')) {
        body = body.substring(1);
      }
    } else if (body.startsWith('N')) {
      body = body.substring(1);
    }

    final text = '$prefix$body';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
