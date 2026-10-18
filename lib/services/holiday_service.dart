import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../common/bond_accrued_interest.dart';
import '../common/stock_row_format.dart';
import '../config/api_config.dart';

/// Нийтийн амралтын өдрүүд — /bdc/api/holidays-аас нэг удаа татаж,
/// ажлын өдрийн тооцоонд ([addBusinessDays], [bondOrderTradeDate]) бүртгэнэ.
/// Амралт STARTDATE 00:00-аас ENDDATE 00:00 хүртэл — ENDDATE өөрөө ажлын
/// өдөр (жишээ: 11-JUL → 14-JUL = 11, 12, 13; TERM = 3).
class HolidayService {
  HolidayService._();

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<void>? _loading;

  /// Давхар дуудвал нэг хүсэлт л явна; амжилтгүй бол дараа дахин оролдоно
  static Future<void> load() => _loading ??= _load();

  static Future<void> _load() async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConfig.holidays,
        data: {'api': 'holidays', 'data': <String, dynamic>{}},
      );
      final body = res.data;
      if (body?['code']?.toString() != '0' || body?['data'] is! List) {
        _loading = null;
        return;
      }
      setPublicHolidays(daysOf(body!['data'] as List));
    } catch (e) {
      debugPrint('[HolidayService] амралтын өдөр татахад алдаа: $e');
      _loading = null;
    }
  }

  /// API-ийн мөрүүдээс амралтын өдрүүдийг задална ([STARTDATE, ENDDATE))
  @visibleForTesting
  static List<DateTime> daysOf(List rows) {
    final days = <DateTime>[];
    for (final row in rows.whereType<Map>()) {
      final start = parseStockDate(row['STARTDATE']);
      final end = parseStockDate(row['ENDDATE']);
      if (start == null || end == null) continue;
      for (var d = start; d.isBefore(end); d = DateTime(d.year, d.month, d.day + 1)) {
        days.add(d);
      }
    }
    return days;
  }
}
