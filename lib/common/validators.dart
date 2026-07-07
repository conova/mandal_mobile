import '../l10n/app_localizations.dart';

class Validators {
  static String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.validationEmailRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return l10n.validationInvalidFormat;
    return null;
  }

  /// Энгийн заавал бөглөх шалгалт
  static String? validateRequired(
    String? value,
    AppLocalizations l10n, {
    String? fieldName,
  }) {
    final name = fieldName ?? l10n.validationThisField;
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRequired(name);
    }
    return null;
  }

  /// Монголын регистрийн дугаар: 2 кирилл үсэг + 6-8 оронтой тоо
  /// Жишээ: УБ010101, ӨТ86010199
  static String? validateMongolianRegister(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRegisterRequired;
    }
    final v = value.trim().toUpperCase();
    final regex = RegExp(r'^[А-ЯӨҮЁ]{2}\d{6,8}$');
    if (!regex.hasMatch(v)) {
      return l10n.validationRegisterInvalid;
    }
    return null;
  }

  /// Монголын утасны дугаар: 8 оронтой, 6/7/8/9-ээр эхэлнэ
  static String? validateMongolianPhone(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationPhoneRequired;
    }
    final v = value.trim();
    final regex = RegExp(r'^[6-9]\d{7}$');
    if (!regex.hasMatch(v)) {
      return l10n.validationInvalidFormat;
    }
    return null;
  }

  /// Хүний нэр: хоосон биш, зөвхөн үсэг (кирилл/латин), зай, зураас
  static String? validateName(
    String? value,
    AppLocalizations l10n, {
    String? fieldName,
  }) {
    final name = fieldName ?? l10n.firstName;
    if (value == null || value.trim().isEmpty) {
      return l10n.validationEnterField(name);
    }
    final regex = RegExp(r"^[A-Za-zА-Яа-яӨөҮүЁё][A-Za-zА-Яа-яӨөҮүЁё\s\-]*$");
    if (!regex.hasMatch(value.trim())) {
      return l10n.validationLettersOnly(name);
    }
    return null;
  }
}
