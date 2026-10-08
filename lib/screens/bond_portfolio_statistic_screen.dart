import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../models/market_instrument.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import 'components/bond/bond_payment_schedule.dart';
import 'components/bond/bond_statistic_skeleton_loader.dart';

class BondPortfolioStatisticScreen extends StatefulWidget {
  const BondPortfolioStatisticScreen({super.key});

  @override
  State<BondPortfolioStatisticScreen> createState() => _BondPortfolioStatisticScreenState();
}

class _BondPortfolioStatisticScreenState extends State<BondPortfolioStatisticScreen> {
  /// 1 — Нийт авсан өгөөж, 2 — Ирээдүйд авах өгөөж
  int _selectedFilter = 1;

  bool _isLoading = true;
  List<MarketInstrument> _holdings = const [];

  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    Future.microtask(_fetch);
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('filter')) {
      _selectedFilter = args['filter'] as int;
    }
  }

  Future<void> _fetch() async {
    try {
      final rows = await context.read<AuthService>().getMyBonds();
      if (!mounted) return;
      setState(() {
        _holdings = MarketInstrument.listFromJson(rows);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 100) return;
    if (velocity < 0 && _selectedFilter == 1) {
      setState(() => _selectedFilter = 2);
    } else if (velocity > 0 && _selectedFilter == 2) {
      setState(() => _selectedFilter = 1);
    }
  }

  /// Бондын хүүгийн төлбөрийн хуваарь — огноо, дүн, төлөгдсөн эсэх.
  List<({DateTime date, double amount, bool paid})> _paymentsOf(
    MarketInstrument bond,
  ) {
    final start = parseStockDate(bond.startDate);
    final end = parseStockDate(bond.endDate);
    final months = BondSchedule.monthsOf(bond.payType);

    final schedule = BondSchedule.build(
      start: start,
      end: end,
      payPeriod: bond.payType,
      nextPayday: start,
    );

    if (schedule == null || months == null || months == 0) {
      return const <({DateTime date, double amount, bool paid})>[];
    }

    final principal = (bond.currentBal ?? 0) * (bond.stockPrice ?? 0);
    final annualRate = (bond.intRate ?? 0) / 100;

    final List<({DateTime date, double amount, bool paid})> results = [];
    DateTime periodStart = schedule.start;

    for (var i = 1; i <= schedule.total; i++) {
      final periodEnd = DateTime(
        schedule.start.year,
        schedule.start.month + months * i,
        schedule.start.day,
      );

      final daysInPeriod = periodEnd.difference(periodStart).inDays;
      final coupon = principal *
          annualRate *
          (daysInPeriod / 365) *
          (1 - ((bond.stockFee ?? 0) > 100 ? 100 : (bond.stockFee ?? 0)) / 100);

      results.add((
        date: periodEnd,
        amount: coupon,
        paid: i <= schedule.paid,
      ));

      periodStart = periodEnd;
    }

    return results;
  }

  List<
      ({
        MarketInstrument bond,
        DateTime date,
        double amount,
        int index,
        int total,
      })> _getFilteredPayments() {
    final List<
        ({
          MarketInstrument bond,
          DateTime date,
          double amount,
          int index,
          int total,
        })> results = [];

    for (final bond in _holdings) {
      final payments = _paymentsOf(bond);
      for (int i = 0; i < payments.length; i++) {
        final p = payments[i];
        final isMatch = _selectedFilter == 1 ? p.paid : !p.paid;
        if (isMatch) {
          results.add((
            bond: bond,
            date: p.date,
            amount: p.amount,
            index: i + 1,
            total: payments.length,
          ));
        }
      }
    }

    if (_selectedFilter == 1) {
      // Received: Newest first
      results.sort((a, b) => b.date.compareTo(a.date));
    } else {
      // Future: Soonest first
      results.sort((a, b) => a.date.compareTo(b.date));
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final filteredPayments = _getFilteredPayments();

    double totalValue = 0;
    for (final p in filteredPayments) {
      totalValue += p.amount;
    }

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        toolbarHeight: 70,
        scrolledUnderElevation: 0.0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _isScrolled ? extendedColors.neutral500 : Colors.transparent,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildSegmentedTabs(theme, extendedColors, l10n),
                  const SizedBox(height: 16),
                  if (!_isLoading && _holdings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: extendedColors.bgSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedFilter == 2
                                    ? '${l10n.futureReturn}:'
                                    : '${l10n.totalReturnReceived}:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: extendedColors.neutral200,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              formatStockAmount(totalValue),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: extendedColors.neutral100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Bond rows
                    if (_isLoading)
                      const BondStatisticSkeletonLoader(itemCount: 5)
                    else if (_holdings.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/safe_box.png',
                                height: 180,
                                errorBuilder: (_, _, _) => const SizedBox(height: 140),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.nothingYet,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: extendedColors.neutral100,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  l10n.growAssetsPrompt,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: extendedColors.neutral200,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: 130,
                                child: CustomButton(
                                  onPressed: () {
                                    // Home (main) руу буцаж бондын tab-ийг нээнэ
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/main',
                                      (route) => false,
                                      arguments: {'tab': 1},
                                    );
                                  },
                                  label: l10n.buyBond,
                                  size: CustomButtonSize.medium,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: filteredPayments
                            .map(
                              (p) => _buildPaymentRow(p, theme, extendedColors, l10n),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Segmented toggle — "Нийт авсан" / "Ирээдүйд авах"
  Widget _buildSegmentedTabs(
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    Widget tab(int filter, String label) {
      final isSelected = _selectedFilter == filter;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _selectedFilter = filter),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? extendedColors.bgBase : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? extendedColors.neutral100
                    : extendedColors.neutral200,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          tab(1, l10n.receivedTab),
          tab(2, l10n.futureTab),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    ({
      MarketInstrument bond,
      DateTime date,
      double amount,
      int index,
      int total,
    }) item,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.bond.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.neutral100,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item.bond.subtitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: extendedColors.neutral200,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.couponPayment} ${item.index}/${item.total}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: extendedColors.neutral200,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildPaymentValue(item, theme, extendedColors, l10n),
        ],
      ),
    );
  }

  Widget _buildPaymentValue(
    ({
      MarketInstrument bond,
      DateTime date,
      double amount,
      int index,
      int total,
    }) item,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final isForeign = item.bond.curCode != 'MNT';
    final dateStr = formatStockDate(item.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatStockAmount(item.amount, isForeign: isForeign),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: extendedColors.neutral100,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          dateStr.replaceAll('/', '.'),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w300,
            color: extendedColors.neutral200,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
