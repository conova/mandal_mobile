import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../models/market_instrument.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_svg_icon.dart';
import '../widgets/custom_snackbar.dart';
import 'components/bond/bond_payment_schedule.dart';

class BondPortfolioScreen extends StatefulWidget {
  const BondPortfolioScreen({super.key});

  @override
  State<BondPortfolioScreen> createState() => _BondPortfolioScreenState();
}

class _BondPortfolioScreenState extends State<BondPortfolioScreen> {
  bool _isLoading = true;
  List<MarketInstrument> _holdings = const [];
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;

  /// Төлбөрийн хуваарийг дэлгэрүүлж харуулсан бондууд (symbol)
  final Set<String> _expandedSymbols = {};

  /// Бондын нийт дүн (₮) — home-ийн хөрөнгийн задаргаа API-аас
  double? _bondTotal;

  /// USD ханш (amountMnt/amount) — ойролцоо $ дүн тооцоход
  double? _usdRate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(_fetch);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if (offset > 50 && !_showStickyHeader) {
      setState(() => _showStickyHeader = true);
    } else if (offset <= 50 && _showStickyHeader) {
      setState(() => _showStickyHeader = false);
    }
  }

  Future<void> _fetch() async {
    try {
      final auth = context.read<AuthService>();
      // Миний бонд + задаргааг зэрэг татна (задаргаа нь header-ийн дүн)
      final results = await Future.wait([
        auth.getMyBonds(),
        auth
            .getAssetBreakdown()
            .catchError((_) => <Map<String, dynamic>>[]),
      ]);
      if (!mounted) return;

      final breakdown = results[1];
      double? bondTotal;
      double? usdRate;
      for (final item in breakdown) {
        usdRate = (item['usdRate'] as num?)?.toDouble();
        final type = item['type']?.toString() ?? '';
        if (type == 'bond' || type == 'bonds') {
          bondTotal = (item['amountMnt'] as num?)?.toDouble();
        }
      }

      setState(() {
        _holdings = MarketInstrument.listFromJson(results[0]);
        _bondTotal = bondTotal;
        _usdRate = usdRate;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, theme, extendedColors, l10n),
                const SizedBox(height: 20),
                // Өгөөжийн хураангуй — дэлгэрэнгүйг статистик дэлгэц дээр үзнэ
                _buildYieldSummaryCard(theme, extendedColors, l10n),
                const SizedBox(height: 28),
                // My Bond section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.myBond,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Table header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.bondName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral200,
                        ),
                      ),
                      Text(
                        l10n.amountPieces,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral200,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Bond rows
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_holdings.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/images/safe_box.png',
                          height: 101,
                          errorBuilder: (_, _, _) => const SizedBox(height: 80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noBondsYet,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: extendedColors.neutral100,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            l10n.startInvestingPrompt,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral100,
                              fontWeight: FontWeight.w200
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 130,
                          child: CustomButton(
                            variant: CustomButtonVariant.purple,
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
                            size: CustomButtonSize.small,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                else
                  Column(
                    children: _holdings
                        .map(
                          (bond) =>
                          _buildBondRow(bond, theme, extendedColors, l10n),
                    )
                        .toList(),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Positioned(
            top: topPadding + 20,
            left: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _showStickyHeader
                    ? [
                        BoxShadow(
                          color: extendedColors.neutral100.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: const CircleBackButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [extendedColors.purple200, extendedColors.bgBase],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              // Icon мөрийн голд (Back товч Positioned-оор Stack-д байгаа)
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: extendedColors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: CustomSvgIcon(
                      'bank-note-01',
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.bonds,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 8),
            _buildAmountText(
              formatStockAmount(_bondTotal ?? 0),
              theme,
              extendedColors,
            ),
            const SizedBox(height: 4),
            Text(
              // USD ханш задаргаанаас тооцоологдвол ойролцоо $ дүн
              l10n.approxUsd(
                formatStockAmount(
                  _usdRate == null || _usdRate == 0
                      ? 0
                      : (_bondTotal ?? 0) / _usdRate!,
                  isForeign: true,
                ).replaceAll('\$', ''),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.purple500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountText(String amount, ThemeData theme, ExtendedColors extendedColors) {
    final dotIndex = amount.indexOf('.');
    if (dotIndex == -1) {
      return Text(
        amount,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: extendedColors.neutral100,
        ),
      );
    }

    final integerPart = amount.substring(0, dotIndex);
    final decimalPart = amount.substring(dotIndex);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: integerPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          TextSpan(
            text: decimalPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }

  /// Өгөөжийн хураангуй карт — мөр бүр статистик дэлгэц рүү шилжүүлнэ
  Widget _buildYieldSummaryCard(
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    double sumOf(double? Function(MarketInstrument b) pick) =>
        _holdings.fold(0.0, (sum, b) => sum + (pick(b) ?? 0));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal:16, vertical: 6),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildYieldRow(
            label: l10n.totalReturnReceived,
            amount: formatStockAmount(sumOf((b) => b.rcvYield), decimals: 0),
            valueColor: extendedColors.neutral100,
            theme: theme,
            extendedColors: extendedColors,
            onTap: () => Navigator.pushNamed(
              context,
              '/bond_portfolio_statistic',
              arguments: {'filter': 1},
            ),
          ),
          _buildYieldRow(
            label: l10n.futureReturn,
            amount:
                formatStockAmount(sumOf((b) => b.expYield), decimals: 0),
            valueColor: extendedColors.purple,
            theme: theme,
            extendedColors: extendedColors,
            onTap: () => Navigator.pushNamed(
              context,
              '/bond_portfolio_statistic',
              arguments: {'filter': 2},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYieldRow({
    required String label,
    required String amount,
    required Color valueColor,
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: extendedColors.neutral200,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w300,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 10),
            CustomSvgIcon(
              'chevron-right',
              size: 18,
              color: extendedColors.neutral300,
            ),
          ],
        ),
      ),
    );
  }

  /// Бондын хүүгийн төлбөрийн хуваарь — огноо, дүн, төлөгдсөн эсэх.
  /// Эхлэх/дуусах огноо эсвэл давтамж дутуу бол хоосон жагсаалт.
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

    // Үндсэн дүн = ширхэг × үнэ; хүүг хоногийн зөрүүгээр тооцно
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
      final coupon = principal * annualRate * (daysInPeriod / 365) * (1 - ((bond.stockFee ?? 0) > 100 ? 100 : (bond.stockFee ?? 0))/100);

      results.add((
        date: periodEnd,
        // Сүүлийн төлбөрт үндсэн төлбөр нэмж олгогдоно
        //amount: i == schedule.total ? coupon + principal : coupon,
        amount: coupon,
        paid: i <= schedule.paid,
      ));

      periodStart = periodEnd;
    }

    return results;
  }

  /// Бондын нэг мөр — дарахад хүүгийн төлбөрийн хуваарь дэлгэрнэ
  Widget _buildBondRow(
    MarketInstrument bond,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final isExpanded = _expandedSymbols.contains(bond.symbol);
    final payments = isExpanded
        ? _paymentsOf(bond)
        : const <({DateTime date, double amount, bool paid})>[];

    void toggle() => setState(() {
      if (isExpanded) {
        _expandedSymbols.remove(bond.symbol);
      } else {
        _expandedSymbols.add(bond.symbol);
      }
    });

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: extendedColors.neutral500)),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: toggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                                bond.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: extendedColors.neutral100,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                bond.subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: extendedColors.neutral200,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: extendedColors.bgSecondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (bond.isForeign
                                    ? l10n.foreign
                                    : (bond.isOpen ? l10n.open : l10n.closed))
                                .toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: extendedColors.neutral100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRowValue(bond, theme, extendedColors, l10n),
                ],
              ),
            ),
          ),
          if (isExpanded && payments.isNotEmpty) ...[
            _buildScheduleBlock(payments, theme, extendedColors, l10n),
          ]
          else if(isExpanded)...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      l10n.noPaymentsYet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: extendedColors.neutral200,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
          // Дэлгэрүүлэх/хураах сум — мөрийн доод талд голлоно
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: toggle,
            child: SizedBox(
              height: 32,
              width: double.infinity,
              child: Center(
                child: CustomSvgIcon(
                  isExpanded ? 'chevron-up' : 'chevron-down',
                  size: 20,
                  color: extendedColors.neutral300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Хуваарьт төлбөрүүд" — төлөгдсөн нь чагттай, хүлээгдэж буй нь дугуйтай
  Widget _buildScheduleBlock(
    List<({DateTime date, double amount, bool paid})> payments,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scheduledPayments,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 12),
          for (final p in payments)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (p.paid)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: extendedColors.primaryMain,
                    )
                  else
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: extendedColors.neutral400,
                          width: 2,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Text(
                    formatStockDate(p.date).replaceAll('/', '.'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: extendedColors.neutral200,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatStockAmount(p.amount, decimals: 0),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Мөрийн баруун багана — эзэмшиж буй дүн, доор нь "Хүү - X% | Nш"
  Widget _buildRowValue(
    MarketInstrument bond,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final isForeign = bond.curCode != 'MNT';
    final bal = bond.currentBal ?? 0;
    final value = bal * (bond.stockPrice ?? 0);
    final pieces = formatStockAmount(bal, decimals: 0, isForeign: isForeign)
        .replaceAll('\u20ae', '')
        .replaceAll(r'$', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatStockAmount(value, isForeign: isForeign),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: extendedColors.neutral100,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          '${l10n.interestRateShort} - ${formatIntRate(bond.intRate)} | '
          '$pieces${l10n.pieces}',
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
