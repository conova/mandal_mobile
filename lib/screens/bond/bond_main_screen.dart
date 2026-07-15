import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/bond/bond_market_card.dart';
import '../components/bond/pledge_bond_banner.dart';
import '../components/bond/my_bond_card.dart';
import '../../common/stock_row_format.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/extended_colors.dart';

class BondMainScreen extends StatefulWidget {
  const BondMainScreen({super.key});

  @override
  State<BondMainScreen> createState() => _BondMainScreenState();
}

class _BondMainScreenState extends State<BondMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _myBondsLoading = true;
  List<Map<String, dynamic>> _myBonds = const [];

  bool _bondListLoading = true;
  List<Map<String, dynamic>> _bondList = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(_fetchMyBonds);
    Future.microtask(_fetchBondList);
  }

  Future<void> _fetchMyBonds() async {
    try {
      final auth = context.read<AuthService>();
      final rows = await auth.getMyBonds();
      if (!mounted) return;
      setState(() {
        _myBonds = rows;
        _myBondsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _myBondsLoading = false);
    }
  }

  Future<void> _fetchBondList() async {
    try {
      final auth = context.read<AuthService>();
      final rows = await auth.getBondList();
      if (!mounted) return;
      setState(() {
        _bondList = rows;
        _bondListLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _bondListLoading = false);
    }
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
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: extendedColors.neutral100,
              unselectedLabelColor: extendedColors.neutral400,
              indicatorColor: extendedColors.primaryMain,
              indicatorWeight: 3,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(text: l10n.buyBond),
                Tab(text: l10n.sellBond),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuyTab(l10n, extendedColors, theme),
          _buildSellTab(l10n, extendedColors, theme),
        ],
      ),
    );
  }

  Widget _buildBuyTab(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    // /stocks/bondlist-ийг MARKET талбараар анхдагч/хоёрдогч гэж хуваана
    final primary = _bondList
        .where((b) => b['MARKET']?.toString().toLowerCase() == 'primary')
        .toList();
    final secondary = _bondList
        .where((b) => b['MARKET']?.toString().toLowerCase() != 'primary')
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
            _buildSectionHeader(
              l10n.primaryMarket,
              extendedColors,
              theme,
              extendedColors.primaryMain,
            ),
            ..._buildBondCards(primary, l10n, extendedColors),
            const SizedBox(height: 40),
          ],
          if (secondary.isNotEmpty) ...[
            _buildSectionHeader(
              l10n.secondaryMarket,
              extendedColors,
              theme,
              extendedColors.primaryMain,
            ),
            ..._buildBondCards(secondary, l10n, extendedColors),
          ],
        ],
      ],
    );
  }

  /// Бондын картуудыг хооронд нь Divider-тэй жагсаана
  List<Widget> _buildBondCards(
    List<Map<String, dynamic>> bonds,
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
  Widget _buildBondListCard(Map<String, dynamic> bond, AppLocalizations l10n) {
    final isOpen = bond['ISOPEN']?.toString() == '1';
    final term = bond['TERM']?.toString() ?? '';
    // Захиалгын явц: ORDEREDAMT / AMT
    final progress = orderProgress(bond['ORDEREDAMT'], bond['AMT']);

    return BondMarketCard(
      bond,
      title:
          (bond['STOCKNAME'] ?? bond['COMPNAME'] ?? bond['SYMBOL'])
              ?.toString() ??
          '',
      subtitle: (bond['COMPNAME2'] ?? bond['TYPENAME'])?.toString() ?? '',
      status: isOpen ? l10n.open : l10n.closed,
      tenure: term.isEmpty
          ? '-'
          : (num.tryParse(term) != null ? '$term сар' : term),
      yield: formatIntRate(bond['INTRATE']),
      totalAmount: formatCompactAmount(
        bond['AMT'],
        languageCode: Localizations.localeOf(context).languageCode,
      ),
      progress: progress,
      payday: bond['PAYDAY']?.toString(),
      market: bond['MARKET']?.toString(),
      progressLabel: progress == null
          ? ''
          : formatStockAmount(
              bond['ORDEREDAMT'],
              isForeign: bond['ISFOREIGN']?.toString() == '1',
              decimals: 0,
            ),
      progressLabel2: progress == null
          ? ''
          : formatStockAmount(
              bond['AMT'],
              isForeign: bond['ISFOREIGN']?.toString() == '1',
              decimals: 0,
            ),
      context: context,
    );
  }

  Widget _buildSellTab(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const PledgeBondBanner(),
        const SizedBox(height: 48),
        _buildSectionHeader(
          l10n.myBond,
          extendedColors,
          theme,
          extendedColors.primaryMain,
        ),
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
          ..._myBonds.map(
            (bond) => _buildMyBondCard(bond, l10n, extendedColors),
          ),
      ],
    );
  }

  /// /stocks/mybonds мөрөөс MyBondCard угсарна
  Widget _buildMyBondCard(
    Map<String, dynamic> bond,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    final isForeign = bond['ISFOREIGN']?.toString() == '1';
    final isOpen = bond['ISOPEN']?.toString() == '1';
    final symbol = bond['SYMBOL']?.toString() ?? '';
    final name =
        (bond['STOCKNAME'] ?? bond['COMPNAME'] ?? symbol)?.toString() ?? '';

    return MyBondCard(
      title: name,
      subtitle: (bond['COMPNAME2'] ?? bond['TYPENAME'])?.toString() ?? '',
      status: isForeign ? l10n.foreign : (isOpen ? l10n.open : l10n.closed),
      statusBgColor: isOpen
          ? extendedColors.primary100
          : extendedColors.bgSecondary,
      statusTextColor: isOpen
          ? extendedColors.primaryMain
          : extendedColors.neutral100,
      ownedAmount: formatStockAmount(bond['AMT'], isForeign: isForeign),
      interestRate: formatIntRate(bond['INTRATE']),
      onSellPressed: () => Navigator.pushNamed(
        context,
        '/bond_sell',
        arguments: {'symbol': symbol, 'name': name},
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    ExtendedColors extendedColors,
    ThemeData theme,
    Color underlineColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: underlineColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
