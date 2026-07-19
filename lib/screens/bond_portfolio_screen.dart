import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../models/market_instrument.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_svg_icon.dart';
import '../widgets/custom_snackbar.dart';

class BondPortfolioScreen extends StatefulWidget {
  const BondPortfolioScreen({super.key});

  @override
  State<BondPortfolioScreen> createState() => _BondPortfolioScreenState();
}

class _BondPortfolioScreenState extends State<BondPortfolioScreen> {
  int _selectedFilter = 0;

  bool _isLoading = true;
  List<MarketInstrument> _holdings = const [];

    /// Бондын нийт дүн (₮) — home-ийн хөрөнгийн задаргаа API-аас
  double? _bondTotal;

  /// USD ханш (amountMnt/amount) — ойролцоо $ дүн тооцоход
  double? _usdRate;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetch);
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
        final type = item['type']?.toString() ?? '';
        if (type == 'bond' || type == 'bonds') {
          bondTotal = (item['amountMnt'] as num?)?.toDouble();
        } else if (type == 'usd' || type == 'dollar') {
          final usd = (item['amount'] as num?)?.toDouble() ?? 0;
          final mnt = (item['amountMnt'] as num?)?.toDouble() ?? 0;
          if (usd > 0 && mnt > 0) usdRate = mnt / usd;
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

  /// Жагсаалт дээр зүүн тийш swipe — дараагийн, баруун тийш — өмнөх filter
  void _onListSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    // Санамсаргүй жижиг хөдөлгөөнийг тоохгүй
    if (velocity.abs() < 100) return;
    setState(() {
      if (velocity < 0 && _selectedFilter < 2) {
        _selectedFilter++;
      } else if (velocity > 0 && _selectedFilter > 0) {
        _selectedFilter--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final filterLabels = [
      l10n.ownedAmountLabel,
      l10n.totalReturnReceived,
      l10n.futureReturn,
    ];

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, theme, extendedColors, l10n),
            const SizedBox(height: 24),
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
            // Filter chips
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filterLabels.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? extendedColors.purple
                            : extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        filterLabels[index],
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: isSelected
                              ? extendedColors.bgBase
                              : extendedColors.neutral100,
                        ),
                      ),
                    ),
                  );
                },
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
                    // Баруун баганын нэр сонгосон filter-ээ дагана
                    switch (_selectedFilter) {
                      1 => l10n.totalReturnReceived,
                      2 => l10n.futureReturn,
                      _ => l10n.amountPieces,
                    },
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
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/home');
                        },
                        label: l10n.add,
                        size: CustomButtonSize.small,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            else
              // Жагсаалт дээр баруун/зүүн swipe хийж filter шилжүүлнэ
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: _onListSwipe,
                child: Column(
                  children: _holdings
                      .map(
                        (bond) =>
                            _buildBondRow(bond, theme, extendedColors, l10n),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 8),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 24),
            // Statistics section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.statistics,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              theme: theme,
              extendedColors: extendedColors,
              icon: 'coins-stacked',
              label: l10n.totalReturnReceived,
              amount: '0.00₮',
              buttonLabel: l10n.view,
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              theme: theme,
              extendedColors: extendedColors,
              icon: 'calendar-check',
              label: l10n.futureReturn,
              amount: '0.00₮',
              buttonLabel: l10n.view,
            ),
            const SizedBox(height: 24),
            // Time filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildTimeFilter(theme, extendedColors),
            ),
            const SizedBox(height: 40),
          ],
        ),
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
              // Back товч зүүн талд, icon мөрийн голд
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CircleBackButton(),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: extendedColors.purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CustomSvgIcon(
                        'bank-note-01',
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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

  Widget _buildBondRow(
    MarketInstrument bond,
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
                        bond.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: extendedColors.neutral100,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        bond.subtitle,
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
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bond.isForeign
                        ? l10n.foreign
                        : (bond.isOpen ? l10n.open : l10n.closed),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Flexible биш — агуулгаараа хэмжигдэж баруун захад наалдана
          // (Expanded + Flexible хослол сул зайг хувааж дүнг голд гацаадаг)
          _buildRowValue(bond, theme, extendedColors, l10n),
        ],
      ),
    );
  }

  /// Мөрийн баруун баганын утга — сонгосон filter-ээс хамаарна:
  ///   0 — Эзэмшиж буй дүн (ширхэг × дундаж үнэ, доор нь хүү | ширхэг)
  ///   1 — Нийт авсан өгөөж (RCVYEILD, доор нь авсан тоо)
  ///   2 — Ирээдүйд авах өгөөж (EXPYEILD, доор нь үлдсэн тоо)
  Widget _buildRowValue(
    MarketInstrument bond,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final cnt = bond.divCnt ?? 0;
    final total = bond.divTotal ?? 0;

    final String amountText;
    final Color amountColor;
    final String subText;

    switch (_selectedFilter) {
      case 1:
        final yield_ = bond.rcvYield ?? 0;
        amountText = formatStockAmount(yield_, isForeign: bond.isForeign);
        // Өгөөж авсан бол ягаанаар тодруулна
        amountColor = yield_ > 0
            ? extendedColors.purple500
            : extendedColors.neutral100;
        subText = cnt > 0 ? l10n.timesReceived(cnt, total) : '$cnt/$total';
      case 2:
        final yield_ = bond.expYield ?? 0;
        amountText = formatStockAmount(yield_, isForeign: bond.isForeign);
        amountColor = extendedColors.neutral100;
        subText = bond.term;
      default:
        // Эзэмшиж буй дүн = ширхэг × дундаж үнэ
        final bal = bond.currentBal ?? 0;
        final value = bal * (bond.avgPrice ?? 0);
        amountText = formatStockAmount(value, isForeign: bond.isForeign);
        amountColor = extendedColors.neutral100;
        subText =
            '${l10n.interestRateShort} - ${formatIntRate(bond.intRate)} | '
            '${formatStockAmount(bal, decimals: 0).replaceAll('₮', '')}${l10n.pieces}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amountText,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w400,
            color: amountColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral300,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required String icon,
    required String label,
    required String amount,
    required String buttonLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CustomSvgIcon(icon, color: extendedColors.neutral100, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CustomSvgIcon('info-circle', size: 16, color: extendedColors.neutral400),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
              label: buttonLabel,
              size: CustomButtonSize.small,
              variant: CustomButtonVariant.tertiary,
              minWidth: 72,
              onPressed: (){},
          )
        ],
      ),
    );
  }

  Widget _buildTimeFilter(ThemeData theme, ExtendedColors extendedColors) {
    final filters = ['7Х', '1С', '3С', '1Ж', 'Бүгд'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: filters.map((label) {
        final isLast = label == 'Бүгд';
        return Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.normal,
            color: isLast ? extendedColors.neutral100 : extendedColors.neutral300,
          ),
        );
      }).toList(),
    );
  }
}
