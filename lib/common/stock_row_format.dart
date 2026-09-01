/// /stocks/* API мөрүүдийн (mystocks, mybonds, nbo) дундын форматлагчид.
library;

/// AMT г.м. тоон утгыг мянгачилж, валютын тэмдэгтэй буцаана:
///   7428770000 → "7,428,770,000.00₮" (isForeign бол "...$")
///   null/хоосон → "-"
/// [decimals] — бутархайн орны тоо (progress label г.м. дээр 0 ашиглана)
String formatStockAmount(dynamic raw, {bool isForeign = false, int decimals = 2}) {
  final formatted = formatNumbers(raw, decimals: decimals);
  return isForeign ? '$formatted\$' : '$formatted₮';
}

String formatNumbers(dynamic raw, {int decimals = 0}) {
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
  return dotIdx == -1 ? whole : '$whole${str.substring(dotIdx)}';
}

/// "2026/07/18", "2026.07.18", "2026-07-18" → DateTime (болохгүй бол null)
/// Мөн "01-AUG-26" гэх мэт форматыг дэмжинэ.
DateTime? parseStockDate(dynamic raw) {
  final s = raw?.toString() ?? '';
  if (s.isEmpty) return null;

  final parts = s.split(RegExp(r'[/.\-]'));
  if (parts.length < 3) return null;

  // Standard YYYY-MM-DD or similar where first part is year
  var y = int.tryParse(parts[0]);
  var m = int.tryParse(parts[1]);
  var d = int.tryParse(parts[2]);

  if (y != null && m != null && d != null && y > 1000) {
    return DateTime(y, m, d);
  }

  // Handle "DD-MON-YY" (e.g. 01-AUG-26)
  final day = int.tryParse(parts[0]);
  final yearShort = int.tryParse(parts[2]);
  if (day != null && yearShort != null && parts[1].length == 3) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final month = months.indexOf(parts[1].toUpperCase()) + 1;
    if (month > 0) {
      final year = 2000 + yearShort;
      return DateTime(year, month, day);
    }
  }

  return null;
}

/// DateTime → "2026/02/10"
String formatStockDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}/${two(date.month)}/${two(date.day)}';
}

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
