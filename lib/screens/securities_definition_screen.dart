import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'dart:convert';

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
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
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
                    onPressed: _html.isEmpty ? null : _downloadHtml,
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
