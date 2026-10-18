import 'package:html/parser.dart' as html_parser;

/// Гэрээ / нөхцөлийн агуулгыг HtmlWidget-д бэлдэнэ. HTML нь `\n`, `\t`-г хоосон
/// зай болгон нийлүүлдэг тул:
///   • сервэрээс `\\n` / `\\t` гэж escape хийгдэж ирсэн бол жинхэнэ тэмдэгт болгоно
///   • `\n` → `<br>`, `\t` → 4 хоосон зай
///   • HTML tag-тай үед block tag-ийн (`<p>`, `<li>` г.м.) хажуудах мөр
///     шилжилтийг хаяна — эс бөгөөс илүү хоосон мөр гарна
///   • tag-гүй энгийн текстийн `&`, `<`, `>`-ийг escape хийнэ
String prepareHtmlContent(String content) {
  var text = content
      .replaceAll(r'\r\n', '\n')
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\t', '\t')
      .replaceAll('\r\n', '\n');
  if (text.trim().isEmpty) return '—';

  final isHtml = RegExp(r'<[a-zA-Z/!][^>]*>').hasMatch(text);
  if (isHtml) {
    text = text.replaceAllMapped(
      RegExp(
        r'\s*(</?(?:p|div|ul|ol|li|h[1-6]|table|thead|tbody|tr|td|th|br|hr|blockquote)\b[^>]*>)\s*',
        caseSensitive: false,
      ),
      (m) => m[1]!,
    );
  } else {
    text = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
  return text
      .replaceAll('\n', '<br>')
      .replaceAll('\t', '&nbsp;&nbsp;&nbsp;&nbsp;');
}

/// Contracts API-ийн бүх текстээс (intro, sections[].content г.м.)
/// [cssClass] class-тай HTML элементүүдийг олж, outerHtml-ийг нь нийлүүлж
/// буцаана. Олдоогүй бол null.
String? extractHtmlByClass(Object? data, String cssClass) {
  final found = <String>[];
  void walk(Object? node) {
    if (node is Map) {
      node.values.forEach(walk);
    } else if (node is List) {
      node.forEach(walk);
    } else if (node is String && node.contains(cssClass)) {
      final fragment = html_parser.parseFragment(node);
      for (final el in fragment.querySelectorAll('.$cssClass')) {
        // .terms дотор дахин .terms байвал зөвхөн гаднахыг нь авна
        var parent = el.parent;
        var nested = false;
        while (parent != null) {
          if (parent.classes.contains(cssClass)) nested = true;
          parent = parent.parent;
        }
        if (!nested) found.add(el.outerHtml);
      }
    }
  }

  walk(data);
  return found.isEmpty ? null : found.join('\n');
}
