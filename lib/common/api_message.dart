import '../theme/app_state_manager.dart';

/// API хариунаас идэвхтэй хэлний дагуу мессеж сонгоно.
///
/// Сервер алдаа/амжилтын хариугаа 2 хэлээр өгдөг:
/// ```json
/// { "message": "Нэвтрэх эрх буруу байна", "messageen": "Invalid credentials" }
/// ```
/// Монгол хэл дээр `message`, бусад хэл дээр `messageen`-ийг харуулна
/// (аль нь байхгүй бол нөгөөгөөр нь нөхнө).
String? apiMessage(dynamic body) {
  if (body is! Map) return null;
  final mn = body['message']?.toString();
  final en = body['messageen']?.toString();

  final isMongolian = AppStateManager.instance.locale.languageCode == 'mn';
  final preferred = isMongolian ? mn : en;
  final value = (preferred == null || preferred.isEmpty)
      ? (isMongolian ? en : mn)
      : preferred;
  return (value == null || value.isEmpty) ? null : value;
}
