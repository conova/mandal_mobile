import 'dart:math' as math;

/// Хуримтлагдсан хүү тооцох бондын төрөл
enum BondAccrualType {
  /// Анхдагч арилжаа — хуримтлагдсан хүүгүй
  primary,

  /// Хаалттай бонд — захиалгын өдөр хүртэл, Actual/365, татвар хасна
  closed,

  /// Нээлттэй бонд — захиалгын өдөр + 2 хүртэл, Actual/365, татвар хасна
  open,

  /// USD бонд — захиалгын өдөр + 2 хүртэл, 30/360, татваргүй
  usd,
}

/// Бондын мөрийн ISOPEN / ISFOREIGN / MARKET талбараас төрлийг тодорхойлно
BondAccrualType bondAccrualTypeOf({
  required bool isPrimary,
  required bool isForeign,
  required bool isOpen,
}) {
  if (isPrimary) return BondAccrualType.primary;
  if (isForeign) return BondAccrualType.usd;
  if (isOpen) return BondAccrualType.open;
  return BondAccrualType.closed;
}

/// Нэг ширхэг бондын хуримтлагдсан хүү.
///   • [nominal] — нэрлэсэн үнэ (STOCKPRICE)
///   • [intRate] — жилийн хүү, хувиар (INTRATE, 12 = 12%)
///   • [taxPct] — татварын хувь (STOCKFEE, 10 = 10%)
///   • [lastPaid] — сүүлд хүү төлөгдсөн өдөр (байхгүй бол 0)
///
/// Хаалттай: нэрлэсэн × хүү × (захиалгын өдөр − сүүлд төлсөн)/365 × (1 − татвар)
/// Нээлттэй: нэрлэсэн × хүү × (захиалгын өдөр + 2 − сүүлд төлсөн)/365 × (1 − татвар)
/// USD:      нэрлэсэн × хүү × days360(сүүлд төлсөн, захиалгын өдөр + 2)/360
double bondAccruedInterest({
  required BondAccrualType type,
  required double nominal,
  required double intRate,
  required double taxPct,
  required DateTime? lastPaid,
  DateTime? orderDate,
}) {
  if (type == BondAccrualType.primary || lastPaid == null) return 0;
  final today = _dateOnly(orderDate ?? DateTime.now());
  final from = _dateOnly(lastPaid);
  final rate = intRate / 100;

  switch (type) {
    case BondAccrualType.closed:
    case BondAccrualType.open:
      final to = type == BondAccrualType.open
          ? today.add(const Duration(days: 2))
          : today;
      final days = math.max(0, to.difference(from).inDays);
      final tax = taxPct.clamp(0, 100) / 100;
      return nominal * rate * days / 365 * (1 - tax);
    case BondAccrualType.usd:
      final days =
          math.max(0, days360(from, today.add(const Duration(days: 2))));
      return nominal * rate * days / 360;
    case BondAccrualType.primary:
      return 0;
  }
}

/// Excel-ийн DAYS360 (US/NASD 30/360) — сар бүрийг 30 хоног гэж тооцно
int days360(DateTime start, DateTime end) {
  var d1 = start.day;
  var d2 = end.day;
  if (d1 == 31) d1 = 30;
  if (d2 == 31 && d1 >= 30) d2 = 30;
  return (end.year - start.year) * 360 +
      (end.month - start.month) * 30 +
      (d2 - d1);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
