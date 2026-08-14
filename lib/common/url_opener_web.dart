import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web-д URL-ыг шинэ tab-д нээх (`target="_blank"`).
void openUrlInNewTab(String url) {
  web.window.open(url, '_blank');
}

/// Web-д HTML контентыг blob URL болгож шинэ tab-д нээнэ.
/// (Auth header шаардлагатай хуудсыг app-аар татаад browser-т үзүүлэхэд)
void openHtmlInNewTab(String html) {
  final blob = web.Blob(
    [html.toJS].toJS,
    web.BlobPropertyBag(type: 'text/html'),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
}
