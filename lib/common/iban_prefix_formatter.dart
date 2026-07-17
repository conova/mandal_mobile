import 'package:flutter/services.dart';

/// IBAN-ий "MN" угтварыг хамгаална — хэрэглэгч устгах/өөрчлөх боломжгүй.
class IbanPrefixFormatter extends TextInputFormatter {
  static const String prefix = 'MN';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text.toUpperCase();

    // Хэрэв "MN123..." гэсэн бүтэн IBAN хуулж тавьбал (Paste) "MN" давхардахаас сэргийлнэ
    if (newText.startsWith('$prefix$prefix')) {
      newText = newText.substring(prefix.length);
    }

    // Хэрэв угтвар байхгүй эсвэл эвдэрсэн бол ("M", "N" эсвэл шууд тоо орж ирвэл)
    if (!newText.startsWith(prefix)) {
      // "MN" үсэг хаана ч байсан цэвэрлээд зөвхөн арын биеийг авна
      String body = newValue.text;
      if (body.startsWith('M') || body.startsWith('m')) {
        body = body.substring(1);
        if (body.startsWith('N') || body.startsWith('n')) {
          body = body.substring(1);
        }
      } else if (body.startsWith('N') || body.startsWith('n')) {
        body = body.substring(1);
      }
      newText = '$prefix$body';
    }

    int cursorPosition = newValue.selection.end;

    // Хэрэглэгч "MN"-ийг устгах гэж оролдсон бол курсерийг "MN"-ий ард түгжинэ
    if (cursorPosition < prefix.length) {
      cursorPosition = prefix.length;
    }

    // Хэрэв текстийн урт өөрчлөгдсөн бол курсерийн байрлалыг зөрүүгээр нь тохируулна
    // Энэ нь текстийн дунд хэсгээс устгалт хийхэд курсер хамгийн ард руу үсрэхээс сэргийлнэ
    final int lengthDifference = newText.length - newValue.text.length;
    cursorPosition += lengthDifference;

    // Хамгийн захын хамгаалалт: Курсер текстийн уртаас хэтрэхгүй байх
    if (cursorPosition > newText.length) {
      cursorPosition = newText.length;
    }

    return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
