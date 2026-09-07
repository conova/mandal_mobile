import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/bond/bond_market_card.dart';
import '../components/bond/bond_status_info_sheet.dart';
import '../components/bond/pledge_bond_banner.dart';
import '../components/bond/my_bond_card.dart';
import '../../common/stock_row_format.dart';
import '../../models/market_instrument.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/section_title.dart';

class BondMainScreen extends StatefulWidget {
  const BondMainScreen({super.key});

  @override
  State<BondMainScreen> createState() => _BondMainScreenState();
}

class _BondMainScreenState extends State<BondMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _myBondsLoading = true;
  List<MarketInstrument> _myBonds = const [];

  bool _bondListLoading = true;
  List<MarketInstrument> _bondList = const [];

  bool _isScrolled = false;

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
                  color: extendedColors.bgBase,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: extendedColors.neutral500,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: extendedColors.neutral100,
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
    final secondary = _bondList.where((b) => !b.isPrimaryMarket).toList();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 50),
        children: [
          const SizedBox(height: 24),
          if (_bondListLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_bondList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
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
              SectionTitle(l10n.primaryMarket),
              ..._buildBondCards(primary, l10n, extendedColors),
              const SizedBox(height: 40),
            ],
            if (secondary.isNotEmpty) ...[
              SectionTitle(l10n.secondaryMarket),
              ..._buildBondCards(secondary, l10n, extendedColors),
            ],
          ],
        ],
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
          Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
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
    final tenureStr = endDt != null && bond.market == 'Secondary'
        ? formatStockDate(endDt)
        : orderEndDate != null && bond.market == 'Primary'
          ? formatStockDate(orderEndDate)
          : (bond.term.isEmpty
            ? '-'
            : (num.tryParse(bond.term) != null ? '${bond.term} сар' : bond.term));

    return BondMarketCard(
      bond.raw,
      title: bond.name,
      subtitle: bond.subtitle,
      status: bond.isForeign
          ? l10n.foreign
          : (bond.isOpen ? l10n.open : l10n.closed),
      tenure: tenureStr,
      yield: formatIntRate(bond.intRate),
      totalAmount: formatCompactAmount(
        bond.amt,
        languageCode: Localizations.localeOf(context).languageCode,
      ),
      progress: progress,
      payday: bond.payday,
      market: bond.market,
      progressLabel: progress == null
          ? ''
          : formatStockAmount(
              bond.orderedAmt,
              isForeign: bond.isForeign,
              decimals: 0,
            ),
      progressLabel2: progress == null
          ? ''
          : formatStockAmount(bond.amt, isForeign: bond.isForeign, decimals: 0),
      onInfoTap: () => BondStatusInfoSheet.showForBond(
        context,
        isOpen: bond.isOpen,
        isForeign: bond.isForeign,
      ),
      context: context,
    );
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
          PledgeBondBanner(
            onPledgePressed: () {
              // Барьцаалах бонд байхгүй бол sheet-ээр мэдэгдэнэ
              if (!_myBondsLoading && _myBonds.isEmpty) {
                BondStatusInfoSheet.show(
                  context,
                  title: l10n.sorryTitle,
                  description: l10n.noPledgeBondDesc,
                );
                return;
              }
              Navigator.pushNamed(context, '/pledge_bond_select');
            },
          ),
          const SizedBox(height: 48),
          SectionTitle(l10n.myBond),
          const SizedBox(height: 24),
          if (_myBondsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_myBonds.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
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
            ..._buildMyBondCards(_myBonds, l10n, extendedColors),
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
        widgets.add(
          Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
        );
        widgets.add(
          const SizedBox(height: 25,)
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
    return MyBondCard(
      title: bond.name,
      subtitle: bond.subtitle,
      status: bond.isForeign
          ? l10n.foreign
          : (bond.isOpen ? l10n.open : l10n.closed),
      statusBgColor: bond.isOpen
          ? extendedColors.primary100
          : extendedColors.bgSecondary,
      statusTextColor: bond.isOpen
          ? extendedColors.primaryMain
          : extendedColors.neutral100,
      ownedAmount: formatStockAmount(bond.amt, isForeign: bond.isForeign),
      interestRate: formatIntRate(bond.intRate),
      onInfoTap: () => BondStatusInfoSheet.showForBond(
        context,
        isOpen: bond.isOpen,
        isForeign: bond.isForeign,
      ),
      onSellPressed: () => Navigator.pushNamed(
        context,
        '/bond_sell',
        arguments: bond.raw,
      ),
    );
  }
}
