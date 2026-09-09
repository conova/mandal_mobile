import 'package:flutter/material.dart';
import 'package:mandal_capital/screens/components/bond/bond_market_card_compact.dart';
import 'package:mandal_capital/screens/components/bond/bond_primary_carousel.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../components/bond/my_bond_card.dart';
import '../../common/stock_row_format.dart';
import '../../models/market_instrument.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/section_title.dart';
import '../../widgets/custom_svg_icon.dart';

class BondMainScreen extends StatefulWidget {
  const BondMainScreen({super.key});

  @override
  State<BondMainScreen> createState() => _BondMainScreenState();
}

class _BondMainScreenState extends State<BondMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _myBondsLoading = true;
  List<MarketInstrument> _myBonds = const [];

  bool _bondListLoading = true;
  List<MarketInstrument> _bondList = const [];

  bool _isScrolled = false;

  // Search and Sort State
  String _searchQuery = '';
  String _sortBy = 'yield'; // 'yield' | 'tenure'
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(_fetchMyBonds);
    Future.microtask(_fetchBondList);
  }

  Future<void> _fetchMyBonds() async {
    if (!mounted) return;
    setState(() => _myBondsLoading = true);
    try {
      final auth = context.read<AuthService>();
      final rows = await auth.getMyBonds();
      if (!mounted) return;
      setState(() {
        _myBonds = MarketInstrument.listFromJson(rows);
        _myBondsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _myBondsLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  Future<void> _fetchBondList() async {
    if (!mounted) return;
    setState(() => _bondListLoading = true);
    try {
      final auth = context.read<AuthService>();
      final rows = await auth.getBondList();
      if (!mounted) return;
      setState(() {
        _bondList = MarketInstrument.listFromJson(rows);
        _bondListLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _bondListLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _fetchMyBonds(),
      _fetchBondList(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 120,
        titleSpacing: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 200,
        shape: Border(
          bottom: BorderSide(
            color: _isScrolled
                ? extendedColors.neutral500.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 16, left: 20),
          child: Text(
            l10n.bond,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4), // Outer margin between border & pill
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return extendedColors.bgSecondary; // Color on hover
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return extendedColors.bgSecondary; // Color when tapped/pressed
                  }
                  return null; // Default behavior
                }),
                indicator: BoxDecoration(
                  color: AppColors.bgBase,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: extendedColors.neutral500,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.neutral100,
                unselectedLabelColor: extendedColors.neutral200,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: l10n.buy),
                  Tab(text: l10n.sell),
                ],
              ),
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 1) {
            final bool scrolled = notification.metrics.pixels > 0;
            if (scrolled != _isScrolled) {
              setState(() => _isScrolled = scrolled);
            }
          }
          return false;
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBuyTab(l10n, extendedColors, theme),
            _buildSellTab(l10n, extendedColors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyTab(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    // /stocks/bondlist-ийг зах зээлээр нь анхдагч/хоёрдогч гэж хуваана
    final primary = _bondList.where((b) => b.isPrimaryMarket).toList();
    var secondary = _bondList.where((b) => !b.isPrimaryMarket).toList();

    // Filter secondary list based on search query
    if (_searchQuery.isNotEmpty) {
      secondary = secondary.where((b) =>
        b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b.symbol.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Sort secondary list
    if (_sortBy == 'yield') {
      secondary.sort((a, b) => (b.intRate ?? 0).compareTo(a.intRate ?? 0));
    } else {
      secondary.sort((a, b) {
        final aDate = parseStockDate(a.endDate) ?? DateTime(2099);
        final bDate = parseStockDate(b.endDate) ?? DateTime(2099);
        return aDate.compareTo(bDate);
      });
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 60),
        children: [
          const SizedBox(height: 24),
          if (_bondListLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_bondList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              child: Center(
                child: Text(
                  l10n.noData,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral300,
                  ),
                ),
              ),
            )
          else ...[
            if (primary.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle(l10n.primaryMarket, true, true),
              ),
              const SizedBox(height: 10,),
              BondPrimaryCarousel(bonds: primary),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SectionTitle(l10n.secondaryMarket, false, true),
                  const SizedBox(height: 12),
                  _buildFilterRow(l10n, extendedColors, theme),
                  if (_isSearchExpanded) ...[
                    const SizedBox(height: 12),
                    _buildSearchField(l10n, extendedColors, theme),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (secondary.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                child: Center(
                  child: Text(
                    l10n.noData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  ..._buildBondCards(secondary, l10n, extendedColors).map(
                    (widget) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: widget,
                    ),
                  ),
                ],
              )
          ],
        ],
      ),
    );
  }

  Widget _buildFilterRow(AppLocalizations l10n, ExtendedColors extendedColors, ThemeData theme) {
    return Row(
      children: [
        _buildSortChip(
          label: l10n.yield,
          isActive: _sortBy == 'yield',
          onTap: () => setState(() => _sortBy = 'yield'),
          extendedColors: extendedColors,
          theme: theme,
        ),
        const SizedBox(width: 8),
        _buildSortChip(
          label: l10n.term,
          isActive: _sortBy == 'tenure',
          onTap: () => setState(() => _sortBy = 'tenure'),
          extendedColors: extendedColors,
          theme: theme,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearchExpanded = !_isSearchExpanded;
              if (!_isSearchExpanded) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isSearchExpanded ? extendedColors.neutral100 : extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomSvgIcon(
                  'search-icon',
                  color: _isSearchExpanded ? extendedColors.bgBase : extendedColors.neutral300,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.search,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: _isSearchExpanded ? extendedColors.bgBase : extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ExtendedColors extendedColors,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? extendedColors.neutral100 : extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isActive ? extendedColors.bgBase : extendedColors.neutral100,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, ExtendedColors extendedColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 40,
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: theme.textTheme.bodyMedium?.copyWith(color: extendedColors.neutral100),
        decoration: InputDecoration(
          hintText: l10n.searchByCompanyName,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: extendedColors.neutral300),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomSvgIcon('search-icon', color: extendedColors.neutral300, size: 20),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const CustomSvgIcon('x-icon', size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /// Бондын картуудыг хооронд нь Divider-тэй жагсаана
  List<Widget> _buildBondCards(
    List<MarketInstrument> bonds,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < bonds.length; i++) {
      if (i > 0) {
        widgets.add(
          const SizedBox(height: 10,),
        );
      }
      widgets.add(_buildBondListCard(bonds[i], l10n));
    }
    return widgets;
  }

  /// /stocks/bondlist мөрөөс BondMarketCard угсарна
  Widget _buildBondListCard(MarketInstrument bond, AppLocalizations l10n) {
    // Захиалгын явц: ORDEREDAMT / AMT
    final progress = orderProgress(bond.orderedAmt, bond.amt);

    final endDt = parseStockDate(bond.endDate);
    final orderEndDate = parseStockDate(bond.orderEndDate);

    // Prioritize DateTime objects for the tenure display to enable "X left" format.
    final dynamic tenure = (bond.market == 'Secondary' && endDt != null)
        ? endDt
        : (bond.market == 'Primary' && orderEndDate != null)
            ? orderEndDate
            : (bond.term.isEmpty
                ? '-'
                : (num.tryParse(bond.term) != null
                    ? '${bond.term} ${l10n.monthLabel}'
                    : bond.term));

    return BondMarketCardCompact(
      bond.raw,
      title: bond.companyName,
      tenure: tenure,
      yield: formatIntRate(bond.intRate),
      payday: bond.payday,
      market: bond.market,
      context: context,
    );

    // return BondMarketCard(
    //   bond.raw,
    //   title: bond.name,
    //   subtitle: bond.subtitle,
    //   status: bond.isForeign
    //       ? l10n.foreign
    //       : (bond.isOpen ? l10n.open : l10n.closed),
    //   tenure: tenureStr,
    //   yield: formatIntRate(bond.intRate),
    //   totalAmount: formatCompactAmount(
    //     bond.amt,
    //     languageCode: Localizations.localeOf(context).languageCode,
    //   ),
    //   progress: progress,
    //   payday: bond.payday,
    //   market: bond.market,
    //   progressLabel: progress == null
    //       ? ''
    //       : formatStockAmount(
    //     bond.orderedAmt,
    //     isForeign: bond.isForeign,
    //     decimals: 0,
    //   ),
    //   progressLabel2: progress == null
    //       ? ''
    //       : formatStockAmount(bond.amt, isForeign: bond.isForeign, decimals: 0),
    //   onInfoTap: () => BondStatusInfoSheet.showForBond(
    //     context,
    //     isOpen: bond.isOpen,
    //     isForeign: bond.isForeign,
    //   ),
    //   context: context,
    // );
  }

  Widget _buildSellTab(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 16),
        children: [
          if (_myBondsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_myBonds.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 160),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/safe_box.png',
                      height: 101,
                      width: 101,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.youHaveNoBond,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.youHaveNoBondDesc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildMyBondStatusCard(_myBonds, l10n, extendedColors, theme),
            SectionTitle(l10n.ableToSell, false, false),
            const SizedBox(height: 24),
            ..._buildMyBondCards(_myBonds, l10n, extendedColors),
          ]
        ],
      ),
    );
  }

  Widget _buildMyBondStatusCard(
    List<MarketInstrument> bonds,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    double totalValue = 0;
    double totalWeightYield = 0;

    for (final bond in bonds) {
      final bal = bond.currentBal ?? 0;
      final price = bond.stockPrice ?? bond.closePrice ?? bond.avgPrice ?? 0;
      final value = bal * price;
      totalValue += value;
      totalWeightYield += (bond.intRate ?? 0) * value;
    }

    final avgYield = totalValue > 0 ? totalWeightYield / totalValue : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.owningBond,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatStockAmount(totalValue, decimals: 0),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${avgYield.toStringAsFixed(1)}%',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.primaryMain,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.averageYield,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Миний бондын картуудыг хооронд нь Divider-тэй жагсаана
  List<Widget> _buildMyBondCards(
    List<MarketInstrument> bonds,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < bonds.length; i++) {
      if (i > 0) {
        widgets.add(
          const SizedBox(height: 10,)
        );
      }
      widgets.add(_buildMyBondCard(bonds[i], l10n, extendedColors));
    }
    return widgets;
  }

  /// /stocks/mybonds мөрөөс MyBondCard угсарна
  Widget _buildMyBondCard(
    MarketInstrument bond,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    final endDt = parseStockDate(bond.endDate);
    final orderEndDate = parseStockDate(bond.orderEndDate);
    // Prioritize DateTime objects for the tenure display to enable "X left" format.
    final dynamic tenure = (bond.market == 'Secondary' && endDt != null)
        ? endDt
        : (bond.market == 'Primary' && orderEndDate != null)
        ? orderEndDate
        : (bond.term.isEmpty
        ? '-'
        : (num.tryParse(bond.term) != null
        ? '${bond.term} ${l10n.monthLabel}'
        : bond.term));

    return MyBondCard(
      title: bond.companyName,
      ownedAmount: bond.currentBal ?? 0,
      tenure: tenure,
      interestRate: formatIntRate(bond.intRate),
      onSellPressed: () => Navigator.pushNamed(
        context,
        '/bond_sell',
        arguments: bond.raw,
      ),
    );
  }
}
