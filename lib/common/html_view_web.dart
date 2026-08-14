import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

int _viewSeq = 0;

/// Web-д HTML баримтыг iframe-ээр дэлгэц дотор render хийнэ.
/// (webview_flutter web дээр дэмжигдэхгүй тул үүгээр орлуулна.)
Widget buildHtmlView(String html) {
  final viewType = 'html-doc-view-${_viewSeq++}';
  // Blob URL — srcdoc-оос илүү найдвартай (том баримт, encoding)
  final blob = web.Blob(
    [html.toJS].toJS,
    web.BlobPropertyBag(type: 'text/html'),
  );
  final url = web.URL.createObjectURL(blob);

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
    final iframe = web.HTMLIFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    return iframe;
  });
  return HtmlElementView(viewType: viewType);
}
