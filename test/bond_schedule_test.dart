import 'package:flutter_test/flutter_test.dart';
import 'package:mandal_capital/common/stock_row_format.dart';
import 'package:mandal_capital/screens/components/bond/bond_payment_schedule.dart';

void main() {
  test('sample bond: 23-APR-26 → 21-APR-28, quarterly', () {
    final s = BondSchedule.build(
      start: parseStockDate('23-APR-26'),
      end: parseStockDate('21-APR-28'),
      payPeriod: 'YYYY/Q',
    )!;
    expect(s.total, 8);
    expect(s.dueDates.first, DateTime(2026, 7, 23));
    expect(s.dueDates[6], DateTime(2028, 1, 23));
    // Сүүлийн төлбөр дуусах өдөр
    expect(s.dueDates.last, DateTime(2028, 4, 21));
  });

  test('lastPaid/nextPay relative to today', () {
    final now = DateTime.now();
    final s = BondSchedule.build(
      start: DateTime(now.year - 1, now.month, 1),
      end: DateTime(now.year + 1, now.month, 1),
      payPeriod: 'YYYY/MM',
    )!;
    expect(s.lastPaid!.isAfter(now), isFalse);
    expect(s.nextPay!.isAfter(now), isTrue);
    expect(s.dueDates[s.paid - 1], s.lastPaid);
    expect(s.dueDates[s.paid], s.nextPay);
  });

  test('none paid yet → lastPaid null, next = first due', () {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final s = BondSchedule.build(
      start: start,
      end: DateTime(start.year + 1, start.month, start.day),
      payPeriod: 'YYYY/2',
    )!;
    expect(s.paid, 0);
    expect(s.lastPaid, isNull);
    expect(s.nextPay, s.dueDates.first);
    expect(s.total, 2);
  });

  test('month-end clamp: 31-JAN monthly → 28/29 FEB, 31 MAR', () {
    final s = BondSchedule.build(
      start: DateTime(2027, 1, 31),
      end: DateTime(2027, 4, 30),
      payPeriod: 'YYYY/MM',
    )!;
    expect(s.dueDates, [DateTime(2027, 2, 28), DateTime(2027, 3, 31), DateTime(2027, 4, 30)]);
  });

  test('weekly YYYY/WW', () {
    final s = BondSchedule.build(
      start: DateTime(2027, 1, 1),
      end: DateTime(2027, 1, 29),
      payPeriod: 'YYYY/WW',
    )!;
    expect(s.total, 4);
    expect(s.dueDates.first, DateTime(2027, 1, 8));
  });

  test('yearly / unknown', () {
    expect(BondSchedule.build(start: DateTime(2026, 1, 1), end: DateTime(2029, 1, 1), payPeriod: 'YYYY')!.total, 3);
    expect(BondSchedule.build(start: DateTime(2026, 1, 1), end: DateTime(2029, 1, 1), payPeriod: 'Улирал'), isNull);
  });
}
