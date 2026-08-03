import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

/// Payment Gateway микросервистэй ажиллах client.
/// Bearer JWT auth — `AuthService.accessToken`-ыг ашиглана.
class PaymentService {
  final AuthService _auth;
  final Dio _dio;

  PaymentService(this._auth)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.paymentGatewayUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            contentType: 'application/json',
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _auth.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// QPAY гүйлгээ эхлүүлэх — NEGDI ec1000 (QPAY ordertype).
  /// Хариунд `redirect_url` нь QR data эсвэл QR харуулдаг URL байж болно.
  Future<InitPaymentResult> initQpay({
    required double amount,
    String? description,
    String? ordernum,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/payments',
        data: {
          'amount': amount,
          'kind': 'qpay',
          if (description != null) 'description': description,
          if (ordernum != null) 'ordernum': ordernum,
        },
      );
      return InitPaymentResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw PaymentException(_extractError(e));
    }
  }

  /// NEGDI төлбөрийн линк авах — negdiurl буцаана.
  /// POST https://mandalcapital.mn/dan/api/payment/link
  /// Body: {custid, amount, txntype, action}
  Future<String> getPaymentLink({
    required String custid,
    required num amount,
    String txntype = 'FEE',
    String action = 'QR',
    String currency = 'MNT',
  }) async {
    try {
      final response = await _dio.post(
        // Бүтэн URL — payment gateway-ийн biш dan сервисийн base ашиглана
        ApiConfig.paymentLink,
        data: {
          'custid': custid,
          'amount': amount,
          'txntype': txntype,
          'action': action,
          'currency': currency,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['response'] is Map) {
        final url = (body['response'] as Map)['negdiurl']?.toString();
        if (url != null && url.isNotEmpty) return url;
      }
      throw PaymentException(
        body['title']?.toString() ?? 'Төлбөрийн линк авахад алдаа гарлаа',
      );
    } on DioException catch (e) {
      throw PaymentException(_extractError(e));
    }
  }

  /// Картаар (3DS) гүйлгээ эхлүүлэх — энэ хувилбарт WebView/browser хэрэгтэй
  /// (redirect_url-г задлан үзүүлнэ). Одоо ашиглахгүй.
  Future<InitPaymentResult> initCard({
    required double amount,
    String? description,
    String? ordernum,
    String? returnUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/payments',
        data: {
          'amount': amount,
          'kind': 'card',
          if (description != null) 'description': description,
          if (ordernum != null) 'ordernum': ordernum,
          if (returnUrl != null) 'return_url': returnUrl,
        },
      );
      return InitPaymentResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw PaymentException(_extractError(e));
    }
  }

  /// Гүйлгээний одоогийн status шалгах (server нь NEGDI ec1098-аас татна).
  Future<PaymentStatus> inquiry({
    required int tranid,
    required String checkid,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/payments/$tranid',
        queryParameters: {'checkid': checkid},
      );
      return PaymentStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw PaymentException(_extractError(e));
    }
  }

  /// Гүйлгээг цуцлах.
  Future<String> cancel({
    required int tranid,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/payments/$tranid/cancel',
        data: {'amount': amount},
      );
      final body = response.data as Map<String, dynamic>;
      return body['status']?.toString() ?? 'Unknown';
    } on DioException catch (e) {
      throw PaymentException(_extractError(e));
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final err = data['error'];
      final detail = data['detail'];
      if (err is String && err.isNotEmpty) {
        return detail is String ? '$err — $detail' : err;
      }
    }
    return e.message ?? 'Network error';
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
  @override
  String toString() => message;
}

/// `/v1/payments` POST-ийн хариу
class InitPaymentResult {
  final int tranid;
  final String checkid;
  final String status;
  final String? redirectUrl;
  final String? approvalCode;
  final String? detail;

  const InitPaymentResult({
    required this.tranid,
    required this.checkid,
    required this.status,
    this.redirectUrl,
    this.approvalCode,
    this.detail,
  });

  factory InitPaymentResult.fromJson(Map<String, dynamic> json) {
    return InitPaymentResult(
      tranid: (json['tranid'] as num).toInt(),
      checkid: json['checkid'] as String,
      status: json['status'] as String,
      redirectUrl: json['redirect_url'] as String?,
      approvalCode: json['approval_code'] as String?,
      detail: json['detail'] as String?,
    );
  }
}

/// `/v1/payments/:tranid` GET-ийн хариу (DB row + сервер сүүлд NEGDI-аас татсан)
class PaymentStatus {
  final int tranid;
  final String checkid;
  final String status;
  final double amount;
  final String? currency;
  final String? ordertype;
  final String? paymentMethod;
  final String? approvalCode;
  final String? brand;
  final String? bankname;
  final String? maskedPan;
  final String? detail;
  final int? tokenid;

  const PaymentStatus({
    required this.tranid,
    required this.checkid,
    required this.status,
    required this.amount,
    this.currency,
    this.ordertype,
    this.paymentMethod,
    this.approvalCode,
    this.brand,
    this.bankname,
    this.maskedPan,
    this.detail,
    this.tokenid,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      tranid: (json['tranid'] as num).toInt(),
      checkid: json['checkid'] as String? ?? '',
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String?,
      ordertype: json['ordertype'] as String?,
      paymentMethod: json['payment_method'] as String?,
      approvalCode: json['approval_code'] as String?,
      brand: json['brand'] as String?,
      bankname: json['bankname'] as String?,
      maskedPan: json['masked_pan'] as String?,
      detail: json['detail'] as String?,
      tokenid: (json['tokenid'] as num?)?.toInt(),
    );
  }

  /// PDF section 10-ийн дагуу ангилал
  PaymentStatusCategory get category {
    switch (status) {
      case 'Preparing':
      case 'Transaction expected':
      case 'Authorized':
        return PaymentStatusCategory.pending;
      case 'Approved':
      case 'Partially paid':
      case 'Funded':
      case 'Fully paid':
        return PaymentStatusCategory.success;
      case 'Expired':
      case 'Reversed':
      case 'Cancelled':
      case 'Rejected':
      case 'Refused':
      case 'Closed':
        return PaymentStatusCategory.warning;
      case 'Declined':
      case 'System error':
        return PaymentStatusCategory.error;
      default:
        if (kDebugMode) {
          debugPrint('[Payment] Unknown status: $status');
        }
        return PaymentStatusCategory.pending;
    }
  }

  bool get isTerminal {
    final c = category;
    return c == PaymentStatusCategory.success ||
        c == PaymentStatusCategory.warning ||
        c == PaymentStatusCategory.error;
  }
}

enum PaymentStatusCategory { pending, success, warning, error }
