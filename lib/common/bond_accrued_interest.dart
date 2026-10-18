import 'dart:math' as math;

/// Хуримтлагдсан хүү тооцох бондын төрөл
enum BondAccrualType {
  /// Анхдагч арилжаа — хуримтлагдсан хүүгүй
  primary,

  /// Хаалттай бонд — захиалгын өдөр хүртэл, Actual/365, татвар хасна
  closed,

  /// Нээлттэй бонд — захиалга биелэх өдөр (ажлын SETTLEDAY хоногийн дараа,
  /// анхдагч 2) хүртэл,
  /// Actual/365, татвар хасна
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
///   • [settleDays] — нээлттэй бондын захиалга биелэх ажлын хоног (SETTLEDAY)
///
/// Хаалттай: нэрлэсэн × хүү × (захиалгын өдөр − сүүлд төлсөн)/365 × (1 − татвар)
/// Нээлттэй: нэрлэсэн × хүү × (захиалгын өдөр + ажлын [settleDays] хоног − сүүлд төлсөн)/365 × (1 − татвар)
/// USD:      нэрлэсэн × хүү × days360(сүүлд төлсөн, захиалгын өдөр + 2)/360
double bondAccruedInterest({
  required BondAccrualType type,
  required double nominal,
  required double intRate,
  required double taxPct,
  required DateTime? lastPaid,
  DateTime? orderDate,
  int settleDays = 2,
}) {
  if (type == BondAccrualType.primary || lastPaid == null) return 0;
  final today = _dateOnly(orderDate ?? DateTime.now());
  final from = _dateOnly(lastPaid);
  final rate = intRate / 100;

  switch (type) {
    case BondAccrualType.closed:
    case BondAccrualType.open:
      // Нээлттэй бонд — захиалга ажлын [settleDays] хоногийн дараа биелнэ
      final to = type == BondAccrualType.open
          ? addBusinessDays(today, settleDays)
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

/// Захиалга бүртгэгдэх арилжааны өдөр ([now] — Улаанбаатарын цаг):
///   • ажлын өдөр, арилжаа хаагдахаас ([eTrade], "HH:mm") өмнө — өнөөдөр
///   • ажлын өдөр, [eTrade]-ээс хойш — дараагийн ажлын өдөр
///   • Бямба / Ням / нийтийн амралтын өдөр — дараагийн ажлын өдөр
/// [eTrade] хоосон / танигдахгүй бол цагийн хязгаар тооцохгүй.
/// Захиалга биелэх өдөр = энэ өдрөөс хойш ажлын SETTLEDAY (анхдагч 2) хоног.
DateTime bondOrderTradeDate(DateTime now, {String eTrade = ''}) {
  final today = _dateOnly(now);
  if (!_isBusinessDay(today)) return addBusinessDays(today, 1);
  final cutoff = _parseTime(eTrade);
  if (cutoff != null) {
    final minutes = now.hour * 60 + now.minute;
    if (minutes >= cutoff) return addBusinessDays(today, 1);
  }
  return today;
}

/// "13:00", "13:00:00", "1300" → өдрийн минут (780). Танигдахгүй бол null.
int? _parseTime(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final m = RegExp(r'^(\d{1,2}):?(\d{2})').firstMatch(s);
  if (m == null) return null;
  final h = int.parse(m[1]!), min = int.parse(m[2]!);
  if (h > 23 || min > 59) return null;
  return h * 60 + min;
}

/// Нийтийн амралтын өдрүүд (огноо л, цаггүй) — HolidayService бөглөнө
final Set<DateTime> _holidays = {};

/// Амралтын өдрүүдийг бүртгэнэ — ажлын өдрийн тооцоонд алгасагдана
void setPublicHolidays(Iterable<DateTime> days) {
  _holidays
    ..clear()
    ..addAll(days.map(_dateOnly));
}

bool _isBusinessDay(DateTime d) =>
    d.weekday != DateTime.saturday &&
    d.weekday != DateTime.sunday &&
    !_holidays.contains(_dateOnly(d));

/// [date]-ээс хойш ажлын [days] дахь өдөр (Бямба, Ням гараг болон
/// [setPublicHolidays]-ээр бүртгэсэн амралтын өдрүүдийг алгасна).
DateTime addBusinessDays(DateTime date, int days) {
  var d = _dateOnly(date);
  var left = days;
  while (left > 0) {
    d = d.add(const Duration(days: 1));
    if (_isBusinessDay(d)) left--;
  }
  return d;
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

/// Нэг ширхэг бондоос [from] өдрөөс хойш авах купон (хүүгийн) төлбөрүүд —
/// огноо, дүнтэй.
///   • [dueDates] — хүү төлөгдөх өдрүүд (BondSchedule.dueDates)
///   • [start] — бонд эхэлсэн өдөр (эхний хугацааны эхлэл)
/// Хугацаа бүрийн купон = нэрлэсэн × хүү × хоног/365 × (1 − татвар);
/// USD бонд — хоног нь days360, хуваагч 360, татваргүй (хуримтлагдсан хүүтэй ижил).
/// [from]-оос хойших төлбөр бүтнээрээ орно — эхний хугацааны өмнөх хэсгийг
/// худалдан авагч хуримтлагдсан хүүгээр төлдөг.
List<({DateTime date, double amount})> bondFutureCouponFlows({
  required List<DateTime> dueDates,
  required DateTime start,
  required double nominal,
  required double intRate,
  required double taxPct,
  bool isUsd = false,
  DateTime? from,
}) {
  final today = _dateOnly(from ?? DateTime.now());
  final rate = intRate / 100;
  final tax = isUsd ? 0 : taxPct.clamp(0, 100) / 100;
  final flows = <({DateTime date, double amount})>[];
  var periodStart = _dateOnly(start);
  for (final due in dueDates) {
    final periodEnd = _dateOnly(due);
    if (periodEnd.isAfter(today)) {
      final days = isUsd
          ? days360(periodStart, periodEnd)
          : periodEnd.difference(periodStart).inDays;
      flows.add((
        date: periodEnd,
        amount: nominal * rate * math.max(0, days) / (isUsd ? 360 : 365) *
            (1 - tax),
      ));
    }
    periodStart = periodEnd;
  }
  return flows;
}

/// [bondFutureCouponFlows]-ийн нийлбэр — нэг ширхэгийн ирээдүйн хүү
double bondFutureCoupons({
  required List<DateTime> dueDates,
  required DateTime start,
  required double nominal,
  required double intRate,
  required double taxPct,
  bool isUsd = false,
  DateTime? from,
}) =>
    bondFutureCouponFlows(
      dueDates: dueDates,
      start: start,
      nominal: nominal,
      intRate: intRate,
      taxPct: taxPct,
      isUsd: isUsd,
      from: from,
    ).fold(0.0, (sum, f) => sum + f.amount);

/// YTM rate (жилийн %, Excel XIRR-тэй ижил) — өнөөдөр [price]-ийг төлж
/// (нэгж үнэ + хуримтлагдсан хүү, шимтгэлгүй), купонууд болон дуусах өдөр
/// [nominal]-ийг буцааж авахад олох жилийн өгөөж:
///   price = Σ CFᵢ / (1 + r)^(tᵢ/365),  tᵢ — өнөөдрөөс хойших хоног
/// Тооцоолох боломжгүй (үнэ 0, мөнгөн урсгалгүй, хугацаа дууссан) бол null.
double? bondYtm({
  required double price,
  required List<({DateTime date, double amount})> coupons,
  required double nominal,
  required DateTime maturity,
  DateTime? from,
}) {
  final today = _dateOnly(from ?? DateTime.now());
  final end = _dateOnly(maturity);
  if (price <= 0 || !end.isAfter(today)) return null;

  final flows = <(double, double)>[
    for (final c in coupons)
      if (_dateOnly(c.date).isAfter(today))
        (_dateOnly(c.date).difference(today).inDays / 365, c.amount),
    (end.difference(today).inDays / 365, nominal),
  ];

  // f(r) = Σ CF/(1+r)^t − price; r-ээр буурах функц
  double f(double r) =>
      flows.fold(0.0, (s, cf) => s + cf.$2 / math.pow(1 + r, cf.$1)) - price;

  // Bisection — Newton-оос удаан ч найдвартай (−99% … 1000%)
  var lo = -0.99, hi = 10.0;
  if (f(lo) < 0 || f(hi) > 0) return null;
  for (var i = 0; i < 200; i++) {
    final mid = (lo + hi) / 2;
    if (f(mid) > 0) {
      lo = mid;
    } else {
      hi = mid;
    }
    if (hi - lo < 1e-10) break;
  }
  return (lo + hi) / 2 * 100;
}

/// Бондын бүх хүүгийн төлбөрийн хуваарь — огноо, дүн, төлөгдсөн эсэх.
/// Хугацаа бүрийн купон (хуримтлагдсан хүү, ирээдүйн өгөөжтэй ижил томьёо):
///   нэрлэсэн × тоо × хүү × (дараагийн − өмнөх төлсөн өдөр)/365 × (1 − татвар)
///   USD бонд — хоног нь days360, хуваагч 360, татваргүй.
/// [now] (UB цаг) хүртэлх төлбөр төлөгдсөнд тооцогдоно.
List<({DateTime date, double amount, bool paid})> bondCouponPayments({
  required List<DateTime> dueDates,
  required DateTime start,
  required double nominal,
  required double quantity,
  required double intRate,
  required double taxPct,
  bool isUsd = false,
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());
  final rate = intRate / 100;
  final tax = isUsd ? 0 : taxPct.clamp(0, 100) / 100;
  final results = <({DateTime date, double amount, bool paid})>[];
  var periodStart = _dateOnly(start);
  for (final due in dueDates) {
    final periodEnd = _dateOnly(due);
    final days = isUsd
        ? days360(periodStart, periodEnd)
        : periodEnd.difference(periodStart).inDays;
    results.add((
      date: periodEnd,
      amount: nominal * quantity * rate * math.max(0, days) /
          (isUsd ? 360 : 365) *
          (1 - tax),
      paid: !periodEnd.isAfter(today),
    ));
    periodStart = periodEnd;
  }
  return results;
}
