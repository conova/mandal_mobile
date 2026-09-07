import 'dart:io';

/// Бүх HttpClient (Dio-гийн default adapter-ууд ч мөн) self-signed /
/// буруу сертификатыг хүлээн зөвшөөрдөг болгоно.
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void allowInsecureSsl() {
  HttpOverrides.global = _DevHttpOverrides();
}
