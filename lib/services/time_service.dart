import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

/// Улаанбаатарын бодит цаг — төхөөрөмжийн цаг буруу тохируулагдсан байж
/// болох тул сервэрээс нэг удаа татаж, төхөөрөмжийн цагтай зөрүүг (skew)
/// хадгална. Дараагийн [nowUb] дуудалт сүлжээгүйгээр тооцогдоно.
/// Эх сурвалж (дарааллаар):
///   1. timeapi.io — үнэгүй, түлхүүргүй, UB-ийн орон нутгийн цаг
///   2. mandalcapital.mn-ийн HTTP `Date` header (UTC)
///   3. төхөөрөмжийн UTC цаг + 8
class TimeService {
  TimeService._();

  static const String _timeApiUrl =
      'https://timeapi.io/api/time/current/zone?timeZone=Asia%2FUlaanbaatar';
  static const String _fallbackUrl = 'https://mandalcapital.mn';
  static const Duration _ubOffset = Duration(hours: 8);

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  /// Сервэрийн UTC цаг − төхөөрөмжийн UTC цаг
  static Duration? _skew;
  static Future<void>? _syncing;

  /// Бодит цагийг нэг удаа татна (давхар дуудвал нэг хүсэлт л явна)
  static Future<void> sync() => _syncing ??= _sync();

  static Future<void> _sync() async {
    final serverUtc = await _fromTimeApi() ?? await _fromDateHeader();
    if (serverUtc != null) {
      _skew = serverUtc.difference(DateTime.now().toUtc());
    } else {
      _syncing = null; // дараа дахин оролдоно
    }
  }

  /// timeapi.io — `year, month, day, hour, minute, seconds, milliSeconds`
  /// нь UB-ийн орон нутгийн цаг (timezone тэмдэглэгээгүй) тул −8 цаг хасна
  static Future<DateTime?> _fromTimeApi() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(_timeApiUrl);
      final d = res.data;
      int? n(String k) => int.tryParse(d?[k]?.toString() ?? '');
      final y = n('year'), mo = n('month'), day = n('day');
      if (y == null || mo == null || day == null) return null;
      return DateTime.utc(y, mo, day, n('hour') ?? 0, n('minute') ?? 0,
              n('seconds') ?? 0, n('milliSeconds') ?? 0)
          .subtract(_ubOffset);
    } catch (e) {
      debugPrint('[TimeService] timeapi.io алдаа: $e');
      return null;
    }
  }

  /// Өөрийн сервэрийн HTTP `Date` header — "Sun, 18 Oct 2026 07:50:08 GMT"
  static Future<DateTime?> _fromDateHeader() async {
    try {
      final res = await _dio.head<void>(
        _fallbackUrl,
        options: Options(validateStatus: (_) => true),
      );
      final raw = res.headers.value('date');
      return raw == null ? null : parseHttpDate(raw).toUtc();
    } catch (e) {
      debugPrint('[TimeService] Date header алдаа: $e');
      return null;
    }
  }

  /// Улаанбаатарын одоогийн цаг (огноо/цаг нь UB-ийнх, DateTime-ийн
  /// timezone нь UTC тэмдэглэгээтэй боловч зөвхөн утгыг нь ашиглана)
  static DateTime nowUb() {
    final utc = DateTime.now().toUtc().add(_skew ?? Duration.zero);
    final ub = utc.add(_ubOffset);
    return DateTime(ub.year, ub.month, ub.day, ub.hour, ub.minute, ub.second);
  }

  /// Бодит цаг сервэрээс авагдсан эсэх (false — төхөөрөмжийн цаг)
  static bool get isSynced => _skew != null;
}
