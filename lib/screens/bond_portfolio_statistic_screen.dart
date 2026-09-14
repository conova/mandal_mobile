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
  /// 1 — Нийт авсан өгөөж, 2 — Ирээдүйд авах өгөөж
  int _selectedFilter = 1;

  bool _isLoading = true;
  List<MarketInstrument> _holdings = const [];

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    // Сонгосон таб-ын дагуу нийлбэр дүн
    final totalValue = _holdings.fold<double>(
      0.0,
      (sum, item) =>
          sum +
          ((_selectedFilter == 2 ? item.expYield : item.rcvYield) ?? 0.0),
    );

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _buildSegmentedTabs(theme, extendedColors, l10n),
              const SizedBox(height: 16),
              // Хураангуй дүн — зөвхөн жагсаалт хоосон биш үед
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
              const SizedBox(height: 8,),
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
                          width: 190,
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
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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

  Widget _buildBondRow(
    MarketInstrument bond,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final cnt = bond.divCnt ?? 0;
    final total = bond.divTotal ?? 0;

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
                  '${l10n.yieldCount} $cnt/$total',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: extendedColors.neutral200,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildRowValue(bond, theme, extendedColors, l10n),
        ],
      ),
    );
  }

  /// Мөрийн баруун багана — өгөөжийн дүн, доор нь огноо
  Widget _buildRowValue(
    MarketInstrument bond,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final isForeign = bond.curCode != 'MNT';
    final amount = _selectedFilter == 2
        ? (bond.expYield ?? 0)
        : (bond.rcvYield ?? 0);
    final date = _selectedFilter == 2 ? bond.term : bond.payday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatStockAmount(amount, isForeign: isForeign),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: extendedColors.neutral100,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          date.isEmpty ? '-' : date.replaceAll('/', '.'),
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