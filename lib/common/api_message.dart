import 'package:dio/dio.dart';
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

/// Идэвхтэй хэлний дагуу бэлэн мессеж сонгоно. Сервер `message`-даа
/// англи текст өгдөг endpoint-ууд дээр (жнь /order/cancel) хэрэглэнэ.
String localMessage(String mn, String en) =>
    AppStateManager.instance.locale.languageCode == 'mn' ? mn : en;

/// Dio-ийн алдааг хэрэглэгчид ойлгомжтой мессеж болгоно (идэвхтэй хэлээр).
/// Dio-ийн техникийн текстийг ("The connection errored: Failed host
/// lookup ..." г.м.) хэзээ ч шууд харуулахгүй.
///   1. Сервер хариу өгсөн бол түүний message / messageen
///   2. Интернэт / WiFi холболтгүй, хост олдохгүй
///   3. Хугацаа хэтэрсэн (удаан сүлжээ)
///   4. Серверийн алдаа (5xx) болон бусад HTTP статус
String dioErrorMessage(DioException e) {
  final server = apiMessage(e.response?.data);
  if (server != null) return server;

  switch (e.type) {
    case DioExceptionType.connectionError:
      return _noInternet;
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return localMessage(
        'Сүлжээ удаан байна. Холболтоо шалгаад дахин оролдоно уу.',
        'The connection is slow. Please check your connection and try again.',
      );
    case DioExceptionType.badCertificate:
      return localMessage(
        'Аюулгүй холболт тогтоож чадсангүй. Өөр сүлжээнд холбогдоод дахин оролдоно уу.',
        'Could not establish a secure connection. Try another network.',
      );
    case DioExceptionType.cancel:
      return localMessage('Хүсэлт цуцлагдлаа.', 'The request was cancelled.');
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      if (status >= 500) {
        return localMessage(
          'Серверт түр саатал гарлаа. Хэсэг хугацааны дараа дахин оролдоно уу.',
          'The server is temporarily unavailable. Please try again later.',
        );
      }
      return _generic;
    case DioExceptionType.unknown:
      // Mobile дээр SocketException / HandshakeException энд ирдэг
      if (isNetworkError(e.error ?? e.message)) return _noInternet;
      return _generic;
  }
}

/// Алдааны текст нь сүлжээ / холболтын алдаа эсэх (dart:io-гүйгээр — web-д ч ажиллана)
bool isNetworkError(Object? error) {
  if (error == null) return false;
  final s = error.toString();
  return s.contains('SocketException') ||
      s.contains('Failed host lookup') ||
      s.contains('Network is unreachable') ||
      s.contains('Connection refused') ||
      s.contains('Connection reset') ||
      s.contains('Connection closed') ||
      s.contains('HandshakeException') ||
      s.contains('No address associated with hostname') ||
      s.contains('XMLHttpRequest error') ||
      s.contains('connection errored');
}

String get _noInternet => localMessage(
      'Интернэт холболт алга байна. WiFi эсвэл мобайл датагаа шалгана уу.',
      'No internet connection. Please check your WiFi or mobile data.',
    );

String get _generic => localMessage(
      'Алдаа гарлаа. Дахин оролдоно уу.',
      'Something went wrong. Please try again.',
    );

/// Сүлжээний алдааны мессеж (DioException-гүй газарт хэрэглэнэ)
String get noInternetMessage => _noInternet;
