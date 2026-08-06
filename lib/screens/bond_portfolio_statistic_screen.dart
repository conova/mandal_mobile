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

class BondPortfolioStatisticScreen extends StatefulWidget {
  const BondPortfolioStatisticScreen({super.key});

  @override
  State<BondPortfolioStatisticScreen> createState() => _BondPortfolioStatisticScreenState();
}

class _BondPortfolioStatisticScreenState extends State<BondPortfolioStatisticScreen> {
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

  /// Огноог "2026.2.10 (122 хоног)" хэлбэрээр — үлдсэн хоногтой нь
  String _daysLeftFromToday(String raw, AppLocalizations l10n) {
    final date = parseStockDate(raw);
    if (date == null) return raw.isEmpty ? '-' : raw.replaceAll('/', '.');
    final days = date.difference(DateTime.now()).inDays;
    return '${days.toString()} ${l10n.daysLeft}';
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    // Calculate total amount based on the selected filter
    final totalValue = switch (_selectedFilter) {
      1 => _holdings.fold<double>(0.0, (sum, item) => sum + (item.rcvYield ?? 0.0)),
      2 => _holdings.fold<double>(0.0, (sum, item) => sum + (item.expYield ?? 0.0)),
      _ => _holdings.fold<double>(0.0, (sum, item) => sum + ((item.currentBal ?? 0.0) * (item.stockPrice ?? 0.0))),
    };

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            (switch (_selectedFilter ) {
              1 => l10n.totalReturnReceived,
              2 => l10n.futureReturn,
              _ => l10n.amountPieces,
            }),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral100,
            ),
          ),
        ),
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16,),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      switch (_selectedFilter) {
                        1 => l10n.totalYieldGot,
                        2 => l10n.totalYield,
                        _ => l10n.amountPieces,
                      },
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.end,
                        formatStockAmount(totalValue),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.neutral100,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20,),
            /*// Table header
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
            const SizedBox(height: 16),*/
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
            //const SizedBox(height: 8),
            //Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 24),
          ],
        ),
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
                if (_selectedFilter == 2)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: extendedColors.yellow200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _daysLeftFromToday(bond.term, l10n),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      )
                    )
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: extendedColors.bgSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      bond.isForeign
                          ? l10n.foreign
                          : (bond.isOpen ? l10n.open : l10n.closed),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  )
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
        amountText = formatStockAmount(yield_, isForeign: bond.curCode != 'MNT');
        // Өгөөж авсан бол ягаанаар тодруулна
        amountColor = yield_ > 0
            ? extendedColors.purple500
            : extendedColors.neutral100;
        subText = cnt > 0 ? l10n.timesReceived(cnt, total) : '$cnt/$total';
      case 2:
        final yield_ = bond.expYield ?? 0;
        amountText = formatStockAmount(yield_, isForeign:  bond.curCode != 'MNT');
        amountColor = extendedColors.neutral100;
        subText = bond.term.replaceAll('/', '.');
      default:
      // Эзэмшиж буй дүн = ширхэг × дундаж үнэ
        final bal = bond.currentBal ?? 0;
        //final value = bal * (bond.avgPrice ?? 0);
        final value = bal * (bond.stockPrice ?? 0);
        amountText = formatStockAmount(value, isForeign:  bond.curCode != 'MNT');
        amountColor = extendedColors.neutral100;
        subText =
        '${l10n.interestRateShort} - ${formatIntRate(bond.intRate)} | '
            '${formatStockAmount(bal, decimals: 0, isForeign:  bond.curCode != 'MNT').replaceAll('₮', '')}${l10n.pieces}';
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
            color: extendedColors.neutral200,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
