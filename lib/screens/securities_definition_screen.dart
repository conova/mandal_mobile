import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../common/html_view_stub.dart'
    if (dart.library.html) '../common/html_view_web.dart';
import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';

/// Үнэт цаасны тодорхойлолт — server-ээс HTML-ээр татаж webview-ээр
/// харуулна, PDF болгож татах боломжтой.
///
/// Route args: { lang: 'mn' | 'en' }
class SecuritiesDefinitionScreen extends StatefulWidget {
  const SecuritiesDefinitionScreen({super.key});

  @override
  State<SecuritiesDefinitionScreen> createState() =>
      _SecuritiesDefinitionScreenState();
}

class _SecuritiesDefinitionScreenState
    extends State<SecuritiesDefinitionScreen> {
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _error;
  String _html = '';
  WebViewController? _controller;
  bool _initialized = false;

  /// Татах бүрд нэмэгдэнэ — хоцорсон хариу/timeout шинэ татаж авалтыг
  /// зогсоохоос сэргийлнэ
  int _downloadToken = 0;

  /// PDF үүсгэгч номын сангууд. `loadHtmlString`-ээр ачаалсан хуудсанд
  /// WebView нь `<script src>`-ийг татдаггүй тул эдгээрийг Dart талаас
  /// татаж хуудас руу шууд суулгана.
  static const String _html2canvasUrl =
      '${ApiConfig.baseUrl}/plugins/libs/html2canvas.min.js';
  static const String _jsPdfUrl =
      '${ApiConfig.baseUrl}/plugins/libs/jspdf.umd.min.js';

  /// Нэг татсан эхийг дэлгэц дахин нээгдэхэд ашиглана
  static List<String>? _pdfLibsCache;

  /// Хуудсан доторх jsPDF-ийн `save()`-ийг таслан авч байтуудыг апп руу
  /// дамжуулах JS суваг. WebView нь браузерын download-ыг барьж авдаггүй
  /// тул энэ гүүргүйгээр товч дарахад файл хаашаа ч очихгүй.
  static const String _pdfChannel = 'PdfBridge';

  /// Хуудас ачаалагдмагц оруулах скрипт:
  ///   • хуудсан доторх татах товчийг нуух (аппад өөрийн товч байгаа)
  ///   • `__mcDownloadPdf()` — PDF-ийг өөрөө үүсгээд байтуудыг апп руу
  ///     дамжуулна
  ///
  /// jsPDF-ийн `save()`-д найдахгүй: тэр нь blob үүсгээд браузерын
  /// download эхлүүлдэг бөгөөд WebView үүнийг барьж авдаггүй.
  static const String _pdfBridgeScript = '''
(function () {
  var actions = document.querySelector('.report-actions');
  if (actions) actions.style.display = 'none';

  function post(o) {
    try { $_pdfChannel.postMessage(JSON.stringify(o)); } catch (e) {}
  }

  function target() {
    return document.getElementById('tblData') ||
           document.querySelector('page[size="A4"]') ||
           document.body;
  }

  function build() {
    if (!window.html2canvas || !(window.jspdf && window.jspdf.jsPDF)) {
      post({
        error: 'Номын сан дутуу (html2canvas: ' +
          (window.html2canvas ? 'ok' : 'алга') + ', jsPDF: ' +
          (window.jspdf ? 'ok' : 'алга') + ')'
      });
      return;
    }
    window.html2canvas(target(), {
      scale: 1.5,
      useCORS: true,
      allowTaint: false,
      logging: false,
      backgroundColor: '#ffffff'
    }).then(function (canvas) {
      var imgData = canvas.toDataURL('image/jpeg', 0.95);
      var pdf = new window.jspdf.jsPDF('p', 'mm', 'a4');
      var pageW = pdf.internal.pageSize.getWidth();
      var pageH = pdf.internal.pageSize.getHeight();
      var imgH = (canvas.height * pageW) / canvas.width;

      if (imgH <= pageH) {
        pdf.addImage(imgData, 'JPEG', 0, 0, pageW, imgH);
      } else {
        // А4-өөс урт бол хуудас болгон зүсэж байрлуулна
        var offset = 0;
        while (offset < imgH) {
          pdf.addImage(imgData, 'JPEG', 0, -offset, pageW, imgH);
          offset += pageH;
          if (offset < imgH) pdf.addPage();
        }
      }
      post({ data: pdf.output('datauristring') });
    })['catch'](function (e) {
      post({ error: 'PDF үүсгэхэд алдаа: ' + e });
    });
  }

  // Номын сан хожуу бэлэн болж магадгүй тул 3 секунд хүртэл хүлээнэ
  window.__mcDownloadPdf = function () {
    var tries = 0;
    (function attempt() {
      if (window.html2canvas && window.jspdf && window.jspdf.jsPDF) {
        build();
        return;
      }
      if (++tries > 30) { build(); return; }
      setTimeout(attempt, 100);
    })();
    return 'started';
  };
})();
''';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _fetch();
  }

  Map<String, dynamic> get _args =>
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
      const {};

  String get _lang => _args['lang']?.toString() ?? 'mn';

  /// 'definition' | 'agreement'
  String get _doc => _args['doc']?.toString() ?? 'definition';

  String get _purpose => _args['purpose']?.toString() ?? '';

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthService>();
      // HTML-ийг PDF хөрвүүлэлтэд ашиглахаар татаж авна
      final html = await auth.getDefinitionHtml(
        lang: _lang,
        doc: _doc,
        purpose: _purpose,
      );
      if (!mounted) return;

      if (!kIsWeb) {
        // Server хариу нь text/plain content-type-той тул URL-ээр шууд
        // ачаалбал эх код нь харагддаг — HTML string-ээр ачаална.
        // baseUrl — хуудасны харьцангуй зам бүхий зургууд (лого г.м.)
        // server-ээс зөв ачаалагдана (../../../images → /images)
        // 21cm (A4) өргөнтэй хуудсыг дэлгэцэд багтаах viewport-ыг шууд
        // HTML-д нэмнэ
        final withViewport = html.contains('name="viewport"')
            ? html
            : html.replaceFirst(
                '<head>',
                '<head><meta name="viewport" '
                    'content="width=820, initial-scale=1.0, '
                    'maximum-scale=5.0">',
              );
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..addJavaScriptChannel(
            _pdfChannel,
            onMessageReceived: _onPdfMessage,
          )
          // Скрипт ачаалагдаагүй зэрэг асуудлыг оношлоход
          ..setOnConsoleMessage(
            (m) => debugPrint('[definition webview] ${m.level.name}: '
                '${m.message}'),
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) async {
                // Скриптүүд (html2canvas, jsPDF) ачаалагдсаны дараа
                // гүүрээ суулгана
                final c = _controller;
                if (c != null) await _installPdfSupport(c);
                if (mounted) setState(() => _isLoading = false);
              },
            ),
          )
          ..loadHtmlString(
            withViewport,
            baseUrl: '${ApiConfig.baseUrl}${ApiConfig.userDocs(_doc)}',
          );
        _controller = controller;
        setState(() => _html = html);
      } else {
        setState(() {
          _html = html;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  /// PDF хөрвүүлэгч ачаалагдахгүй харьцангуй замтай ресурс дээр гацдаг
  /// тул src/href-ийн "../../.." замуудыг server-ийн абсолют зам болгоно
  String _htmlForPdf() {
    return _html
        .replaceAll(
          RegExp(r'src="(\.\./)+'),
          'src="${ApiConfig.baseUrl}/',
        )
        .replaceAll(
          RegExp(r'href="(\.\./)+'),
          'href="${ApiConfig.baseUrl}/',
        );
  }

  /// Хуудсан доторх jsPDF-ээс ирсэн PDF — data URI-г тайлж хадгална
  Future<void> _onPdfMessage(JavaScriptMessage message) async {
    final token = _downloadToken;
    try {
      final body = jsonDecode(message.message);
      if (body is! Map) throw const FormatException('Буруу хариу');

      final error = body['error']?.toString();
      if (error != null && error.isNotEmpty) {
        // Шалтгааныг харуулаад HTML-ээр хадгалж хэрэглэгчийг
        // гар хоосон үлдээхгүй
        debugPrint('[definition] PDF алдаа: $error');
        if (mounted) {
          setState(() => _isDownloading = false);
          CustomSnackbar.show(
            context,
            message: 'PDF үүсгэж чадсангүй: $error',
            type: CustomSnackbarType.error,
          );
          await _downloadHtml();
        }
        return;
      }

      final data = body['data']?.toString() ?? '';
      final marker = data.indexOf('base64,');
      if (marker == -1) throw const FormatException('PDF өгөгдөл олдсонгүй');

      final bytes = base64Decode(data.substring(marker + 7));
      final name = body['name']?.toString();
      final path = await FilePicker.saveFile(
        dialogTitle: 'Тодорхойлолт хадгалах',
        fileName: (name == null || name.isEmpty)
            ? '${_doc == 'agreement' ? 'geree' : 'todorhoilolt'}_$_lang.pdf'
            : name,
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: bytes,
      );
      if (path != null && mounted) {
        CustomSnackbar.show(context, message: 'Файл хадгалагдлаа');
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e);
    } finally {
      if (mounted && token == _downloadToken) {
        setState(() => _isDownloading = false);
      }
    }
  }

  /// html2canvas, jsPDF-ийн эхийг татна (нэг л удаа)
  Future<List<String>> _loadPdfLibs() async {
    final cached = _pdfLibsCache;
    if (cached != null) return cached;
    final dio = Dio(
      BaseOptions(
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.plain,
      ),
    );
    final results = await Future.wait([
      dio.get<String>(_html2canvasUrl),
      dio.get<String>(_jsPdfUrl),
    ]);
    final sources = [
      for (final r in results) r.data ?? '',
    ]..removeWhere((s) => s.isEmpty);
    if (sources.length == 2) _pdfLibsCache = sources;
    return sources;
  }

  /// Хуудсанд PDF үүсгэх чадвар суулгана — номын сангууд байхгүй бол
  /// татаж оруулаад, дараа нь гүүрийн скриптийг ажиллуулна.
  Future<void> _installPdfSupport(WebViewController controller) async {
    try {
      final ready = await controller.runJavaScriptReturningResult(
        "(window.html2canvas && window.jspdf) ? 'ok' : 'missing'",
      );
      if (ready.toString().replaceAll('"', '') != 'ok') {
        final libs = await _loadPdfLibs();
        for (final source in libs) {
          await controller.runJavaScript(source);
        }
      }
    } catch (e) {
      debugPrint('[definition] PDF номын сан суулгахад алдаа: $e');
    }
    try {
      await controller.runJavaScript(_pdfBridgeScript);
    } catch (e) {
      debugPrint('[definition] Гүүр суулгахад алдаа: $e');
    }
  }

  /// Хуудсан доторх PDF үүсгэлтийг эхлүүлэхийг оролдоно.
  /// Гүүр суусан эсэхийг буцаана (үр дүн нь JS сувгаар ирнэ).
  Future<bool> _triggerPdf(WebViewController controller) async {
    try {
      final result = await controller.runJavaScriptReturningResult(
        "window.__mcDownloadPdf ? window.__mcDownloadPdf() : 'missing'",
      );
      // Платформоос хамаарч хашилттай ирж болно
      return result.toString().replaceAll('"', '') == 'started';
    } catch (e) {
      debugPrint('[definition] PDF эхлүүлэхэд алдаа: $e');
      return false;
    }
  }

  /// Татах товч — хуудсан доторх PDF үүсгэгчийг ажиллуулна.
  /// Үүсгэгч ачаалагдаагүй (эсвэл web) бол HTML-ээр хадгална.
  Future<void> _download() async {
    if (_isDownloading || _html.isEmpty) return;
    final controller = _controller;
    if (controller == null) {
      await _downloadHtml();
      return;
    }

    final token = ++_downloadToken;
    setState(() => _isDownloading = true);
    try {
      // Гүүр суугаагүй байвал (onPageFinished алдагдсан, эсвэл хуудас
      // дахин ачаалагдсан) энд дахин суулгана
      var started = await _triggerPdf(controller);
      if (!started) {
        await _installPdfSupport(controller);
        started = await _triggerPdf(controller);
      }
      if (!started) {
        // PDF үүсгэгч байхгүй — хуучин зан төлөв рүү шилжинэ
        if (mounted && token == _downloadToken) {
          setState(() => _isDownloading = false);
        }
        await _downloadHtml();
        return;
      }
      // Үр дүн JS сувгаар ирнэ. html2canvas дотроо унавал spinner
      // мөнхөд эргэхээс сэргийлж хугацаа тавина.
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && token == _downloadToken && _isDownloading) {
          setState(() => _isDownloading = false);
        }
      });
    } catch (e) {
      if (mounted && token == _downloadToken) {
        setState(() => _isDownloading = false);
        CustomSnackbar.showError(context, e);
      }
    }
  }

  /// Баримтыг HTML файлаар хадгална — хадгалах байршлаа сонгоно.
  /// (Зургийн замуудыг абсолют болгосон тул browser-ээр нээхэд лого
  /// зэрэг нь зөв харагдана.)
  Future<void> _downloadHtml() async {
    if (_html.isEmpty || _isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final bytes = Uint8List.fromList(utf8.encode(_htmlForPdf()));
      final path = await FilePicker.saveFile(
        dialogTitle: 'Тодорхойлолт хадгалах',
        fileName: '${_doc == 'agreement' ? 'geree' : 'todorhoilolt'}_$_lang.html',
        type: FileType.custom,
        allowedExtensions: ['html'],
        bytes: bytes,
      );
      if (path != null && mounted) {
        CustomSnackbar.show(context, message: 'Файл хадгалагдлаа');
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        leadingWidth: 60,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            _doc == 'agreement' ? l10n.agreementLabel : l10n.securitiesStatement,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
        actions: [
          // PDF татах
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10),
            child: _isDownloading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _html.isEmpty ? null : _download,
                    icon: CustomSvgIcon(
                      'file-download-02',
                      size: 24,
                      color: extendedColors.neutral100,
                    ),
                  ),
          ),
        ],
      ),
      body: _error != null
          ? _buildError(theme, extendedColors)
          : kIsWeb
              // Web дээр webview_flutter дэмжигдэхгүй — шууд PDF
              // татах товч харуулна
              // Web — HTML-ийг iframe-ээр дэлгэц дотор render хийнэ
              ? _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : buildHtmlView(_html)
              : Stack(
                  children: [
                    if (_controller != null)
                      WebViewWidget(controller: _controller!),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
    );
  }

  Widget _buildError(ThemeData theme, ExtendedColors extendedColors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: extendedColors.red),
            const SizedBox(height: 16),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: extendedColors.neutral200,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: CustomButton(label: 'Дахин оролдох', onPressed: _fetch),
            ),
          ],
        ),
      ),
    );
  }
}
