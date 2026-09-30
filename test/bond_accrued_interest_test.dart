import 'package:flutter_test/flutter_test.dart';
import 'package:mandal_capital/common/bond_accrued_interest.dart';

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

  test('open: +2 days, minus tax', () {
    final ai = bondAccruedInterest(
      type: BondAccrualType.open,
      nominal: 100000, intRate: 12, taxPct: 10,
      lastPaid: lastPaid, orderDate: order,
    );
    expect(ai, closeTo(100000 * 0.12 * 31 / 365 * 0.9, 1e-9));
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
}
