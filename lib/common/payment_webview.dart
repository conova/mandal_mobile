import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/webview_screen.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';

/// Төлбөрийн NEGDI линк авч app доторх [WebViewScreen] ('/webview')-ээр
/// нээнэ — DAN E-Mongolia flow-той яг ижил contract:
///   • Төлбөрийн хуудас `mandalapp://payment?result=success` (эсвэл
///     `result=error&message=...`) руу redirect хийхэд webview хаагдаж
///     үр дүн энд буцна.
///   • `mandalapp://home` scheme эсвэл `MandalApp.postMessage(...)` JS
///     bridge-ээр [homeRoute] руу шууд шилжиж болно (default: /main;
///     бүртгэлийн урсгалд /register_success дамжуулна).
///
/// Returns:
///   • 'success' | 'error' | 'cancel' — callback-аас ирсэн үр дүн
///   • null — хэрэглэгч webview-г хаасан, эсвэл home руу шилжсэн
///
/// Линк авах API алдаа өгвөл [PaymentException] шиднэ — дуудагч тал
/// catch хийж toast харуулна.
Future<String?> openPaymentWebview(
  BuildContext context, {
  required num amount,
  String txntype = 'FEE',
  String action = 'QR',
  String title = 'Төлбөр төлөх',
  String homeRoute = '/main',
}) async {
  final custid = context.read<AuthService>().uid ?? '';
  final url = await context.read<PaymentService>().getPaymentLink(
        custid: custid,
        amount: amount,
        txntype: txntype,
        action: action,
      );
  if (!context.mounted) return null;

  final returned = await Navigator.pushNamed(
    context,
    '/webview',
    arguments: {
      'url': url,
      'title': title,
      'callbackPrefix': 'mandalapp://',
      'homeRoute': homeRoute,
    },
  );

  // WebView дотроос homeRoute руу шууд шилжсэн — стек аль хэдийн солигдсон
  if (returned == WebViewScreen.popResultHome) return null;

  if (returned is String) {
    final result = Uri.tryParse(returned)?.queryParameters['result'];
    return (result == null || result.isEmpty)
        ? 'success'
        : result.toLowerCase();
  }
  return null;
}
