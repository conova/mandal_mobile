import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order.dart';
import '../../../services/auth_service.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/order_card.dart';
import '../transaction_history/transaction_period_sheet.dart';

/// Захиалгын түүх tab — orders/history API-аас шүүлтүүр (төрөл, төлөв)
/// болон хугацааны интервалаар татаж харуулна.
class OrderHistoryTab extends StatefulWidget {
  const OrderHistoryTab({super.key});

  @override
  State<OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends State<OrderHistoryTab> {
  bool _isLoading = true;
  List<Order> _orders = const [];

  /// Шүүлтүүр: bond | stock (null — бүгд)
  String? _type;

  /// Шүүлтүүр: done | canceled (null — бүгд)
  String? _status;

  TimePeriod _period = TimePeriod.last3Months;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetch);
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}';

  /// Сонгосон интервалын эхлэх огноо (дуусах нь өнөөдөр, custom-оос бусад)
  (DateTime, DateTime) _dateRange() {
    final now = DateTime.now();
    return switch (_period) {
      TimePeriod.last7Days => (now.subtract(const Duration(days: 7)), now),
      TimePeriod.last1Month => (DateTime(now.year, now.month - 1, now.day), now),
      TimePeriod.last3Months =>
          (DateTime(now.year, now.month - 3, now.day), now),
      TimePeriod.last6Months =>
          (DateTime(now.year, now.month - 6, now.day), now),
      TimePeriod.custom => (
          _customStart ?? DateTime(now.year, now.month - 3, now.day),
          _customEnd ?? now,
        ),
    };
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _orders = const [];
    });
    try {
      final (start, end) = _dateRange();
      final rows = await context.read<AuthService>().getOrderHistory(
            type: _type,
            status: _status,
            start: _fmt(start),
            end: _fmt(end),
          );
      if (!mounted) return;
      setState(() {
        _orders = Order.listFromJson(rows);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      builder: (_) => _OrderHistoryFilterSheet(
        initialType: _type,
        initialStatus: _status,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _type = result['type'];
        _status = result['status'];
      });
      _fetch();
    }
  }

  Future<void> _openPeriodSheet() async {
    final result = await showModalBottomSheet<PeriodResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionPeriodSheet(
        initialPeriod: _period,
        initialStartDate: _customStart,
        initialEndDate: _customEnd,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _period = result.period;
        _customStart = result.startDate;
        _customEnd = result.endDate;
      });
      _fetch();
    }
  }

  /// "Шүүлтүүр" / "Шүүлтүүр 2" — сонгосон шүүлтийн тоо
  String _filterLabel(AppLocalizations l10n) {
    final count = (_type != null ? 1 : 0) + (_status != null ? 1 : 0);
    return count == 0 ? l10n.filter : '${l10n.filter} $count';
  }

  String _periodLabel(AppLocalizations l10n) {
    return switch (_period) {
      TimePeriod.last7Days => l10n.last7Days,
      TimePeriod.last1Month => l10n.last1MonthFilter,
      TimePeriod.last3Months => l10n.last3Months,
      TimePeriod.last6Months => l10n.last6Months,
      TimePeriod.custom => () {
          final (start, end) = _dateRange();
          return '${start.month}.${start.day} - ${end.month}.${end.day}';
        }(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final hasFilter = _type != null || _status != null;

    return RefreshIndicator(
      onRefresh: _fetch,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шүүлтүүр + хугацааны chip-үүд
            Row(
              children: [
                const SizedBox(width: 16),
                _DropdownChip(
                  label: _filterLabel(l10n),
                  isActive: hasFilter,
                  onTap: _openFilterSheet,
                ),
                const SizedBox(width: 8),
                _DropdownChip(
                  label: _periodLabel(l10n),
                  isActive: false,
                  onTap: _openPeriodSheet,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_orders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/empty_history.png',
                        height: 160,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.calendar_month_outlined,
                          size: 80,
                          color: extendedColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.noHistoryFound,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._orders.map(
                (order) => OrderCard(
                  companyName:
                      order.symbol.isNotEmpty && order.symbol != order.name
                          ? order.symbol
                          : order.nameOf(
                              Localizations.localeOf(context).languageCode,
                            ),
                  subtitle: order.nameOf(
                    Localizations.localeOf(context).languageCode,
                  ),
                  amount: formatStockAmount(
                    order.totalAmount,
                    isForeign: order.isForeignCurrency,
                  ),
                  price: formatStockAmount(
                    order.donePrice ?? order.price,
                    isForeign: order.isForeignCurrency,
                  ),
                  execution: order.executionLabel,
                  date: order.orderDateLabel,
                  type: order.isBuy ? OrderType.buy : OrderType.sell,
                  status:
                      order.isOpen ? OrderStatus.open : OrderStatus.closed,
                  market: order.isForeign
                      ? MarketType.foreign
                      : (order.isBond ? MarketType.bond : MarketType.stock),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/order_detail',
                    arguments: {'order': order},
                  ),
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

/// "Шүүлтүүр ▾" загварын chip
class _DropdownChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DropdownChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final fg = isActive ? extendedColors.bgBase : extendedColors.neutral100;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? extendedColors.primaryMain
              : extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: fg,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: fg),
          ],
        ),
      ),
    );
  }
}

/// Төрөл (Бонд/Хувьцаа) + Төлөв (Биелсэн/Цуцалсан) шүүлтүүрийн sheet.
/// Pop үр дүн: {'type': 'bond'|'stock'|null, 'status': 'done'|'canceled'|null}
class _OrderHistoryFilterSheet extends StatefulWidget {
  final String? initialType;
  final String? initialStatus;

  const _OrderHistoryFilterSheet({this.initialType, this.initialStatus});

  @override
  State<_OrderHistoryFilterSheet> createState() =>
      _OrderHistoryFilterSheetState();
}

class _OrderHistoryFilterSheetState extends State<_OrderHistoryFilterSheet> {
  String? _type;
  String? _status;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _status = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(color: extendedColors.bgBase),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: extendedColors.neutral400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.type,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _chip(l10n.bond, _type == 'bond',
                  () => setState(() => _type = _type == 'bond' ? null : 'bond')),
              _chip(
                l10n.stocks,
                _type == 'stock',
                () => setState(
                  () => _type = _type == 'stock' ? null : 'stock',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.orderStatusLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _chip(
                l10n.done,
                _status == 'done',
                () => setState(
                  () => _status = _status == 'done' ? null : 'done',
                ),
              ),
              _chip(
                l10n.canceled,
                _status == 'canceled',
                () => setState(
                  () => _status = _status == 'canceled' ? null : 'canceled',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Divider(height: 1, color: extendedColors.neutral500),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _type = null;
                      _status = null;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: extendedColors.bgSecondary,
                      foregroundColor: extendedColors.neutral100,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      l10n.clearFilter,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      {'type': _type, 'status': _status},
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: extendedColors.bgSecondary,
                      foregroundColor: extendedColors.neutral100,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      l10n.filterAction,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? extendedColors.bgSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? extendedColors.primaryMain
                : extendedColors.neutral400,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w300,
            color: extendedColors.neutral100,
          ),
        ),
      ),
    );
  }
}
