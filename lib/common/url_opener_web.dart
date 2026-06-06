import 'package:web/web.dart' as web;

/// Web-д URL-ыг шинэ tab-д нээх (`target="_blank"`).
void openUrlInNewTab(String url) {
  web.window.open(url, '_blank');
}
