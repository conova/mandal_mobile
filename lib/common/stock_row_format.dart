/// /stocks/* API мөрүүдийн (mystocks, mybonds, nbo) дундын форматлагчид.
library;

/// AMT г.м. тоон утгыг мянгачилж, валютын тэмдэгтэй буцаана:
///   7428770000 → "7,428,770,000.00₮" (isForeign бол "...$")
///   null/хоосон → "-"
/// [decimals] — бутархайн орны тоо (progress label г.м. дээр 0 ашиглана)
String formatStockAmount(dynamic raw, {bool isForeign = false, int decimals = 2}) {
  if (raw == null || raw.toString().isEmpty) return '-';
  final n = num.tryParse(raw.toString().replaceAll(',', ''));
  if (n == null) return raw.toString();
  final str = n.toStringAsFixed(decimals);
  final dotIdx = str.indexOf('.');
  final wholePart = dotIdx == -1 ? str : str.substring(0, dotIdx);
  final whole = wholePart.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  final formatted = dotIdx == -1 ? whole : '$whole${str.substring(dotIdx)}';
  return isForeign ? '$formatted\$' : '$formatted₮';
}

/// "2026/07/18", "2026.07.18", "2026-07-18" → DateTime (болохгүй бол null)
DateTime? parseStockDate(dynamic raw) {
  final s = raw?.toString() ?? '';
  if (s.isEmpty) return null;
  final parts = s.split(RegExp(r'[/.\-]'));
  if (parts.length < 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

/// DateTime → "2026.2.10"
String formatStockDate(DateTime date) =>
    '${date.year}.${date.month}.${date.day}';

/// Захиалгын явц: ordered/total → 0.0..1.0 (аль нэг нь тоо биш эсвэл
/// total ≤ 0 бол null — progress харуулахгүй)
double? orderProgress(dynamic ordered, dynamic total) {
  final o = num.tryParse(ordered?.toString().replaceAll(',', '') ?? '');
  final t = num.tryParse(total?.toString().replaceAll(',', '') ?? '');
  if (o == null || t == null || t <= 0) return null;
  return (o / t).clamp(0.0, 1.0).toDouble();
}

/// INTRATE → "3.5%", null/хоосон → "-"
String formatIntRate(dynamic raw) {
  if (raw == null || raw.toString().isEmpty) return '0%';
  return '$raw%';
}

/// Дүнг сая/тэрбум нэгжээр товчилно (home recommendation-тэй ижил дүрэм):
///   420000000 → "420 сая" / "420M", 5000000000 → "5 тэрбум" / "5B"
///   1 саяас бага бол мянгачилсан бүтэн утга, null → "-"
String formatCompactAmount(dynamic raw, {String languageCode = 'mn'}) {
  if (raw == null || raw.toString().isEmpty) return '-';
  final value = num.tryParse(raw.toString().replaceAll(',', ''));
  if (value == null) return raw.toString();

  final isEnglish = languageCode == 'en';
  String fmt(num v) {
    var s = v.toStringAsFixed(1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s;
  }

  if (value >= 1e12) {
    return isEnglish ? '${fmt(value / 1e12)}T' : '${fmt(value / 1e12)} их наяд';
  }
  if (value >= 1e9) {
    return isEnglish ? '${fmt(value / 1e9)}B' : '${fmt(value / 1e9)} тэрбум';
  }
  if (value >= 1e6) {
    return isEnglish ? '${fmt(value / 1e6)}M' : '${fmt(value / 1e6)} сая';
  }
  return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}
