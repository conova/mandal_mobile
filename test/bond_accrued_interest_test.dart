import 'package:flutter_test/flutter_test.dart';
import 'package:mandal_capital/common/bond_accrued_interest.dart';
import 'package:mandal_capital/services/holiday_service.dart';
import 'package:mandal_capital/screens/components/bond/bond_payment_schedule.dart';

void main() {
  final lastPaid = DateTime(2026, 9, 1);
  final order = DateTime(2026, 9, 30);

  test('closed: Actual/365, no +2, minus tax', () {
    final ai = bondAccruedInterest(
      type: BondAccrualType.closed,
      nominal: 100000, intRate: 12, taxPct: 10,
      lastPaid: lastPaid, orderDate: order,
    );
    expect(ai, closeTo(100000 * 0.12 * 29 / 365 * 0.9, 1e-9));
  });

  test('open: +2 business days, minus tax', () {
    // 2026-09-30 Лхагва → ажлын 2 хоног = 2026-10-02 Баасан (31 хоног)
    final ai = bondAccruedInterest(
      type: BondAccrualType.open,
      nominal: 100000, intRate: 12, taxPct: 10,
      lastPaid: lastPaid, orderDate: order,
    );
    expect(ai, closeTo(100000 * 0.12 * 31 / 365 * 0.9, 1e-9));
  });

  test('open: Friday order settles Tuesday', () {
    // 2026-10-16 Баасан → 2026-10-20 Мягмар
    expect(addBusinessDays(DateTime(2026, 10, 16), 2), DateTime(2026, 10, 20));
    // 2026-10-18 Ням → 2026-10-20 Мягмар
    expect(addBusinessDays(DateTime(2026, 10, 18), 2), DateTime(2026, 10, 20));
    final ai = bondAccruedInterest(
      type: BondAccrualType.open,
      nominal: 100000, intRate: 12, taxPct: 0,
      lastPaid: DateTime(2026, 10, 1), orderDate: DateTime(2026, 10, 16),
    );
    expect(ai, closeTo(100000 * 0.12 * 19 / 365, 1e-9));
  });

  test('usd: days360 to +2, no tax', () {
    final ai = bondAccruedInterest(
      type: BondAccrualType.usd,
      nominal: 1000, intRate: 9, taxPct: 10,
      lastPaid: lastPaid, orderDate: order,
    );
    // 2026-09-01 → 2026-10-02 = 31 (30/360)
    expect(days360(lastPaid, DateTime(2026, 10, 2)), 31);
    expect(ai, closeTo(1000 * 0.09 * 31 / 360, 1e-9));
  });

  test('primary: 0', () {
    expect(
      bondAccruedInterest(
        type: BondAccrualType.primary,
        nominal: 100000, intRate: 12, taxPct: 10,
        lastPaid: lastPaid, orderDate: order,
      ),
      0,
    );
  });

  test('days360 US rule for 31st', () {
    expect(days360(DateTime(2026, 1, 31), DateTime(2026, 3, 31)), 60);
    expect(days360(DateTime(2026, 1, 15), DateTime(2026, 3, 31)), 76);
  });

  test('future coupons: sample bond 23-APR-26 → 21-APR-28 quarterly, from 2026-10-18', () {
    final s = BondSchedule.build(
      start: DateTime(2026, 4, 23),
      end: DateTime(2028, 4, 21),
      payPeriod: 'YYYY/Q',
    )!;
    final sum = bondFutureCoupons(
      dueDates: s.dueDates,
      start: s.start,
      nominal: 100000, intRate: 12, taxPct: 10,
      from: DateTime(2026, 10, 18),
    );
    // 2026-07-23 төлөгдсөн → үлдсэн 7 төлбөр: 2026-07-23 → 2028-04-21
    final days = DateTime(2028, 4, 21).difference(DateTime(2026, 7, 23)).inDays;
    expect(sum, closeTo(100000 * 0.12 * days / 365 * 0.9, 1e-6));
  });

  test('future coupons: none after maturity', () {
    expect(
      bondFutureCoupons(
        dueDates: [DateTime(2026, 1, 1)],
        start: DateTime(2025, 1, 1),
        nominal: 100000, intRate: 12, taxPct: 0,
        from: DateTime(2026, 6, 1),
      ),
      0,
    );
  });

  group('bondYtm', () {
    final today = DateTime(2026, 1, 1);

    test('1 yr single coupon: par → 12%, discount/premium', () {
      final coupons = [(date: DateTime(2027, 1, 1), amount: 12000.0)];
      double ytm(double price) => bondYtm(
            price: price, coupons: coupons, nominal: 100000,
            maturity: DateTime(2027, 1, 1), from: today,
          )!;
      expect(ytm(100000), closeTo(12.0, 1e-6));
      expect(ytm(95000), closeTo((112000 / 95000 - 1) * 100, 1e-6));
      expect(ytm(105000), closeTo((112000 / 105000 - 1) * 100, 1e-6));
    });

    test('sample bond at par + AI ≈ coupon rate after tax', () {
      final s = BondSchedule.build(
        start: DateTime(2026, 4, 23),
        end: DateTime(2028, 4, 21),
        payPeriod: 'YYYY/Q',
      )!;
      final from = DateTime(2026, 10, 18);
      final ai = bondAccruedInterest(
        type: BondAccrualType.closed, nominal: 100000, intRate: 12,
        taxPct: 10, lastPaid: s.lastPaid, orderDate: from,
      );
      final r = bondYtm(
        price: 100000 + ai,
        coupons: bondFutureCouponFlows(
          dueDates: s.dueDates, start: s.start, nominal: 100000,
          intRate: 12, taxPct: 10, from: from,
        ),
        nominal: 100000, maturity: s.end, from: from,
      )!;
      // Татварын дараах 10.8%, улирлын нийлмэл ≈ 11.2%
      expect(r, inInclusiveRange(10.5, 11.5));
    });

    test('matured / zero price → null', () {
      expect(bondYtm(price: 0, coupons: const [], nominal: 1, maturity: DateTime(2027), from: today), isNull);
      expect(bondYtm(price: 1, coupons: const [], nominal: 1, maturity: DateTime(2025), from: today), isNull);
    });
  });

  group('bondOrderTradeDate', () {
    // 2026-10-16 Баасан, 2026-10-17 Бямба, 2026-10-19 Даваа
    test('weekday before ETRADE → today', () {
      expect(bondOrderTradeDate(DateTime(2026, 10, 16, 12, 59), eTrade: '13:00'),
          DateTime(2026, 10, 16));
    });
    test('weekday after ETRADE → next business day', () {
      expect(bondOrderTradeDate(DateTime(2026, 10, 16, 13, 0), eTrade: '13:00'),
          DateTime(2026, 10, 19));
      expect(bondOrderTradeDate(DateTime(2026, 10, 19, 14, 30), eTrade: '13:00:00'),
          DateTime(2026, 10, 20));
    });
    test('weekend → Monday', () {
      expect(bondOrderTradeDate(DateTime(2026, 10, 17, 9)), DateTime(2026, 10, 19));
    });
    test('empty ETRADE → no cutoff', () {
      expect(bondOrderTradeDate(DateTime(2026, 10, 16, 23)), DateTime(2026, 10, 16));
    });
    test('Saturday order settles Wednesday (3 business days ahead)', () {
      final trade = bondOrderTradeDate(DateTime(2026, 10, 17, 9));
      expect(addBusinessDays(trade, 2), DateTime(2026, 10, 21));
    });
    test('SETTLEDAY drives open accrual', () {
      double ai(int settle) => bondAccruedInterest(
            type: BondAccrualType.open, nominal: 100000, intRate: 12,
            taxPct: 0, lastPaid: DateTime(2026, 10, 1),
            orderDate: DateTime(2026, 10, 19), settleDays: settle,
          );
      // Даваа + 0 = 18 хоног, + 2 = Лхагва 20 хоног, + 3 = Пүрэв 21 хоног
      expect(ai(0), closeTo(100000 * 0.12 * 18 / 365, 1e-9));
      expect(ai(2), closeTo(100000 * 0.12 * 20 / 365, 1e-9));
      expect(ai(3), closeTo(100000 * 0.12 * 21 / 365, 1e-9));
    });
  });

  test('bondCouponPayments: MNT tax, USD 30/360 no tax, paid by now', () {
    final dues = [DateTime(2026, 7, 23), DateTime(2026, 10, 23)];
    final mnt = bondCouponPayments(
      dueDates: dues, start: DateTime(2026, 4, 23), nominal: 1000000,
      quantity: 2, intRate: 18.8, taxPct: 10, now: DateTime(2026, 10, 18),
    );
    expect(mnt[0].paid, isTrue);
    expect(mnt[1].paid, isFalse);
    expect(mnt[1].amount, closeTo(2 * 1000000 * 0.188 * 92 / 365 * 0.9, 1e-6));
    final usd = bondCouponPayments(
      dueDates: dues, start: DateTime(2026, 4, 23), nominal: 1000,
      quantity: 1, intRate: 9, taxPct: 10, isUsd: true,
      now: DateTime(2026, 10, 18),
    );
    expect(usd[1].amount, closeTo(1000 * 0.09 * 90 / 360, 1e-9));
  });

  group('holidays', () {
    final rows = [
      {'STARTDATE': '11-JUL-26', 'ENDDATE': '14-JUL-26', 'TERM': '3'},
      {'STARTDATE': '26-NOV-26', 'ENDDATE': '27-NOV-26', 'TERM': '1'},
      {'STARTDATE': '31-DEC-26', 'ENDDATE': '02-JAN-27', 'TERM': '2'},
    ];
    tearDown(() => setPublicHolidays(const []));

    test('days = [STARTDATE, ENDDATE), count == TERM', () {
      final days = HolidayService.daysOf(rows);
      expect(days, [
        DateTime(2026, 7, 11), DateTime(2026, 7, 12), DateTime(2026, 7, 13),
        DateTime(2026, 11, 26),
        DateTime(2026, 12, 31), DateTime(2027, 1, 1),
      ]);
    });

    test('business days skip holidays', () {
      setPublicHolidays(HolidayService.daysOf(rows));
      // Лхагва 11.25 + 2 → Пүрэв 11.26 баяр → Баасан 11.27, Даваа 11.30
      expect(addBusinessDays(DateTime(2026, 11, 25), 2), DateTime(2026, 11, 30));
      // Баярын өдөр захиалбал дараагийн ажлын өдөр
      expect(bondOrderTradeDate(DateTime(2026, 11, 26, 10)), DateTime(2026, 11, 27));
      // Пүрэв 12.31 баяр, Баасан 1.1 баяр → Даваа 1.4
      expect(bondOrderTradeDate(DateTime(2026, 12, 31, 9)), DateTime(2027, 1, 4));
      // ENDDATE өөрөө ажлын өдөр: Даваа 7.13 баяр, Мягмар 7.14 ажлын
      expect(addBusinessDays(DateTime(2026, 7, 10), 1), DateTime(2026, 7, 14));
    });
  });
}
