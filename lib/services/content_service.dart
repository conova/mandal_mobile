import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../config/api_config.dart';

/// Серверээс шинэчлэгддэг статик контент (гэрээ, боловсролын хичээл).
///
/// Апп-ын шинэ хувилбар гаргалгүйгээр агуулгыг сервер талаас засах
/// боломжтой байхын тулд эхлээд API-аас татна; сүлжээ/сервер алдаа
/// гарвал apk дотор савласан asset руу шилжинэ (offline-д ажиллана).
///
/// Татсан үр дүнг session дотор кэшлэнэ — нэг дэлгэц дуудахад
/// дараагийнх нь дахин сүлжээнд гарахгүй.
class ContentService {
  ContentService._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      // Сервер JSON-оо text/plain-ээр өгсөн ч задлах боломжтой байлгана
      responseType: ResponseType.plain,
    ),
  );

  static final Map<String, Map<String, dynamic>> _cache = {};

  /// Гэрээнүүд — /api/mobile/contracts
  static Future<Map<String, dynamic>> contracts() => _fetch(
        url: ApiConfig.mobileContracts,
        assetPath: 'assets/data/contracts.json',
      );

  /// Боловсролын дата — /api/mobile/education-guide
  static Future<Map<String, dynamic>> educationGuide() => _fetch(
        url: ApiConfig.mobileEducationGuide,
        assetPath: 'assets/data/education_guide.json',
      );

  /// Кэшийг цэвэрлэнэ — дараагийн дуудалт серверээс шинээр татна
  static void invalidate() => _cache.clear();

  static Future<Map<String, dynamic>> _fetch({
    required String url,
    required String assetPath,
  }) async {
    final cached = _cache[url];
    if (cached != null) return cached;

    try {
      final response = await _dio.get<String>(url);
      final raw = response.data;
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final body = Map<String, dynamic>.from(decoded);
          _cache[url] = body;
          return body;
        }
      }
      throw const FormatException('Хүлээгдэж буй JSON object ирсэнгүй');
    } catch (e) {
      debugPrint('[ContentService] $url татаж чадсангүй ($e) — asset ашиглана');
      final body = await _loadAsset(assetPath);
      // Asset-ыг кэшлэхгүй — дараагийн оролдлогод сервер рүү дахин хандана
      return body;
    }
  }

  static Future<Map<String, dynamic>> _loadAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}
