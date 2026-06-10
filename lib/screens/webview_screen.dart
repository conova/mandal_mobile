import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart' show navigatorKey;
import '../theme/extended_colors.dart';
import '../widgets/custom_snackbar.dart';
import '../common/url_opener_stub.dart'
    if (dart.library.html) '../common/url_opener_web.dart';

/// Үндсэн WebView дэлгэц — гадаад нэвтрэх / баталгаажуулах URL-уудыг
/// харуулахад ашиглана (жнь: E-Mongolia DAN).
///
/// Route args (`Map<String, dynamic>`):
///   - url: String — нээх URL (заавал)
///   - title: String? — AppBar дээр гарах гарчиг (default: 'Баталгаажуулалт')
///   - callbackPrefix: String? — энэ prefix-ээр эхэлсэн URL руу redirect
///                                болох үед webview-г хааж `pop(req.url)` хийнэ
///   - homeRoute: String? — заасан үед WebView дотроос дараах 2 аргаар
///                          home tab руу шилжүүлж болно:
///       (1) JavaScript bridge — JSON payload-ыг дэмжинэ:
///             window.MandalApp.postMessage(JSON.stringify({
///               action: 'navigate_home',
///               result: 'success' | 'error',   // optional, default 'success'
///               message: 'Алдааны мессеж'       // optional, error үед toast
///             }));
///           Plain string ч ажиллана: `'navigate_home'` → success гэж үзнэ.
///       (2) Custom URL scheme — `mandalapp://home?result=error&message=...`
///           гэсэн query string дэмжинэ.
///   • `result != 'success'` бол home руу шилжсэний дараа `CustomSnackbar`-аар
///     `message` (эсвэл default алдаа) гарна.
///   - homeUrlScheme: String? — home scheme (default: 'mandalapp://home').
///   - jsChannelName: String? — JS bridge нэр (default: 'MandalApp').
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  /// WebView дотроос `Navigator.pushNamedAndRemoveUntil(homeRoute)` дуудах
  /// pop result код. Дуудагч (жнь DAN screen) үүнийг шалгаж, өөрөө мөн
  /// home руу шилжих эсэх шийднэ.
  static const String popResultHome = '__navigate_home__';

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
    final homeRoute = args['homeRoute'] as String?;
    final homeUrlScheme =
        (args['homeUrlScheme'] as String?) ?? 'mandalapp://home';
    final jsChannelName = (args['jsChannelName'] as String?) ?? 'MandalApp';

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
      ..setBackgroundColor(Colors.transparent);

    // JavaScript bridge — webview доторх хуудас `MandalApp.postMessage(...)`
    // дуудаж home руу шилжих action илгээх боломжтой.
    if (homeRoute != null && homeRoute.isNotEmpty) {
      controller.addJavaScriptChannel(
        jsChannelName,
        onMessageReceived: (msg) {
          final cmd = _parseNavigateHomeMessage(msg.message);
          if (cmd != null) {
            _navigateHome(homeRoute, cmd);
          }
        },
      );
    }

    controller
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
            // (1) Home scheme — webview доторх хуудас `mandalapp://home` руу
            // redirect хийж home tab руу шилжүүлж болно. Query string-ээс
            // `result` болон `message` уншина.
            if (homeRoute != null &&
                homeRoute.isNotEmpty &&
                req.url.startsWith(homeUrlScheme)) {
              _navigateHome(homeRoute, _parseNavigateHomeUrl(req.url));
              return NavigationDecision.prevent;
            }
            // (2) Callback URL — баталгаажуулалт амжилттай дуусгасан тохиолдол
            if (callbackPrefix != null &&
                callbackPrefix.isNotEmpty &&
                req.url.startsWith(callbackPrefix)) {
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

  /// JS bridge-ийн ирсэн string-ийг "home руу шилжих" command мөн эсэхийг
  /// шалгаж парс хийнэ. Хүлээн авах формат:
  ///   • Plain string: `"navigate_home"` (case-insensitive) → success
  ///   • JSON: `{"action":"navigate_home","result":"error","message":"..."}`
  ///           эсвэл `{"action":"navigate","route":"/home", ...}`
  /// Returns `null` бол энэ navigate_home command биш.
  _NavigateHomeCommand? _parseNavigateHomeMessage(String raw) {
    final trimmed = raw.trim();
    if (trimmed.toLowerCase() == 'navigate_home') {
      return const _NavigateHomeCommand(result: 'success');
    }
    if (trimmed.startsWith('{')) {
      try {
        final json = jsonDecode(trimmed);
        if (json is Map) {
          final action = json['action']?.toString().toLowerCase();
          final isHome = action == 'navigate_home' ||
              (action == 'navigate' &&
                  (json['route'] == null ||
                      json['route'].toString().isEmpty ||
                      json['route'].toString() == '/home'));
          if (isHome) {
            return _NavigateHomeCommand(
              result: json['result']?.toString().toLowerCase() ?? 'success',
              message: json['message']?.toString(),
            );
          }
        }
      } catch (_) {
        // JSON биш — командаас бүү тооцоолж буцаа
      }
    }
    return null;
  }

  /// `mandalapp://home?result=error&message=...` URL-ээс командыг парс хийнэ.
  _NavigateHomeCommand _parseNavigateHomeUrl(String url) {
    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      return const _NavigateHomeCommand(result: 'success');
    }
    final qp = uri.queryParameters;
    return _NavigateHomeCommand(
      result: (qp['result'] ?? 'success').toLowerCase(),
      message: qp['message'],
    );
  }

  /// WebView-г хааж, root navigator-аас бүх стек цэвэрлэн `homeRoute`
  /// руу шилжинэ. Дуудагч талд мөн дохио өгөхөөр pop result-ыг
  /// [WebViewScreen.popResultHome] утгаар буцаана.
  /// `cmd.result != 'success'` бол home tab дээр гарсны дараа `CustomSnackbar`
  /// гарч ирнэ.
  void _navigateHome(String homeRoute, _NavigateHomeCommand cmd) {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    // Эхлээд webview-г pop хийж (caller-т signal явуулна), дараа нь
    // root stack-аас home руу шилжинэ.
    navigator.pop(WebViewScreen.popResultHome);
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil(homeRoute, (_) => false);

    // Алдаатай үед — home tab нээгдсэний дараа toast гаргана. Шинэ frame-н
    // дараа `navigatorKey.currentContext` нь home screen-ийн context болсон
    // байх ёстой.
    if (cmd.result != 'success') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;
        final fallback =
            cmd.result == 'cancel' || cmd.result == 'cancelled'
                ? 'Баталгаажуулалт цуцлагдлаа'
                : 'Баталгаажуулалтын явцад алдаа гарлаа';
        CustomSnackbar.show(
          ctx,
          message: (cmd.message?.isNotEmpty ?? false) ? cmd.message! : fallback,
          type: CustomSnackbarType.error,
        );
      });
    }
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

/// WebView-ийн `navigate_home` командын парс хийсэн нэгж.
///   • `result` — 'success' | 'error' | 'cancel' | бусад
///   • `message` — алдааны үед хэрэглэгчид харуулах текст (optional)
class _NavigateHomeCommand {
  final String result;
  final String? message;
  const _NavigateHomeCommand({required this.result, this.message});
}
