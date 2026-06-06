import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/extended_colors.dart';
import '../common/url_opener_stub.dart'
    if (dart.library.html) '../common/url_opener_web.dart';

/// Үндсэн WebView дэлгэц — гадаад нэвтрэх / баталгаажуулах URL-уудыг
/// харуулахад ашиглана (жнь: E-Mongolia DAN).
///
/// Route args (`Map&lt;String, dynamic&gt;`):
///   - url: String — нээх URL (заавал)
///   - title: String? — AppBar дээр гарах гарчиг (default: 'Баталгаажуулалт')
///   - callbackPrefix: String? — энэ prefix-ээр эхэлсэн URL руу redirect
///                                болох үед webview-г хааж `pop(true)` хийнэ
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _init();
  }

  void _init() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final url = args['url'] as String?;
    final callbackPrefix = args['callbackPrefix'] as String?;

    if (url == null || url.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'URL хоосон байна';
      });
      return;
    }

    // Web дээр webview_flutter дэмжихгүй учир URL-ыг шинэ tab-д нээгээд
    // дэлгэцийг шууд буцаана. Mobile дээр WebViewController ашиглана.
    if (kIsWeb) {
      openUrlInNewTab(url);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (err) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = err.description;
              });
            }
          },
          onNavigationRequest: (req) {
            if (callbackPrefix != null &&
                callbackPrefix.isNotEmpty &&
                req.url.startsWith(callbackPrefix)) {
              // Callback URL руу redirect болсон → webview-г success-р хаах
              Navigator.of(context).pop(req.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final title = (args['title'] as String?) ?? 'Баталгаажуулалт';

    return Scaffold(
      backgroundColor: extendedColors?.bgBase ?? theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
