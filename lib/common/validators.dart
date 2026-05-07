class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  /// Энгийн заавал бөглөх шалгалт
  static String? validateRequired(String? value, {String fieldName = 'Энэ талбар'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName хоосон байна';
    }
    return null;
  }

  /// Монголын регистрийн дугаар: 2 кирилл үсэг + 6-8 оронтой тоо
  /// Жишээ: УБ010101, ӨТ86010199
  static String? validateMongolianRegister(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Регистрийн дугаар оруулна уу';
    }
    final v = value.trim().toUpperCase();
    final regex = RegExp(r'^[А-ЯӨҮЁ]{2}\d{6,8}$');
    if (!regex.hasMatch(v)) {
      return 'Регистрийн дугаар буруу байна';
    }
    return null;
  }

  /// Монголын утасны дугаар: 8 оронтой, 6/7/8/9-ээр эхэлнэ
  static String? validateMongolianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Утасны дугаар оруулна уу';
    }
    final v = value.trim();
    final regex = RegExp(r'^[6-9]\d{7}$');
    if (!regex.hasMatch(v)) {
      return 'Утасны дугаар буруу байна';
    }
    return null;
  }

  /// Хүний нэр: хоосон биш, зөвхөн үсэг (кирилл/латин), зай, зураас
  static String? validateName(String? value, {String fieldName = 'Нэр'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName оруулна уу';
    }
    final regex = RegExp(r"^[A-Za-zА-Яа-яӨөҮүЁё][A-Za-zА-Яа-яӨөҮүЁё\s\-]*$");
    if (!regex.hasMatch(value.trim())) {
      return '$fieldName зөвхөн үсэг байна';
    }
    return null;
  }
}
