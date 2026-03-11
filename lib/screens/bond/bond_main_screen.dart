import 'package:flutter/material.dart';
import '../components/bond/bond_market_card.dart';
import '../components/bond/pledge_bond_banner.dart';
import '../components/bond/my_bond_card.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';

class BondMainScreen extends StatefulWidget {
  const BondMainScreen({super.key});

  @override
  State<BondMainScreen> createState() => _BondMainScreenState();
}

class _BondMainScreenState extends State<BondMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader(
          l10n.primaryMarket,
          extendedColors,
          theme,
          extendedColors.primaryMain,
        ),
        BondMarketCard(
          title: 'Net Capital',
          subtitle: 'Нэт Капитал',
          status: l10n.closed,
          tenure: '12 сар',
          yield: '19.5%',
          totalAmount: '900 сая',
          progress: 0.02,
          progressLabel: '900,000₮ /900,000,000₮',
          onBuyPressed: () => Navigator.pushNamed(context, '/bond_detail'),
        ),
        Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
        BondMarketCard(
          title: 'Lend.mn',
          subtitle: 'Лэнд.мн',
          status: l10n.open,
          tenure: '12 сар',
          yield: '19.5%',
          totalAmount: '1 тэрбум',
          progress: 0.45,
          progressLabel: '210,500,000₮ /500,000,000₮',
          onBuyPressed: () {},
        ),
        const SizedBox(height: 16),
        Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                extendedColors.primaryMain,
                extendedColors.primary300,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          l10n.secondaryMarket,
          extendedColors,
          theme,
          extendedColors.neutral100,
        ),
        BondMarketCard(
          title: 'Simple',
          subtitle: 'Симпл',
          status: l10n.closed,
          tenure: '12 сар',
          yield: '19.5%',
          totalAmount: '1 тэрбум',
          onBuyPressed: () {},
        ),
        Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
        BondMarketCard(
          title: 'Magna',
          subtitle: 'Магна',
          status: l10n.closed,
          tenure: '12 сар',
          yield: '12.5%',
          totalAmount: '800 сая',
          onBuyPressed: () {},
        ),
        Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
        BondMarketCard(
          title: 'GSB Capital',
          subtitle: 'ЖИЭСБ капитал',
          status: l10n.open,
          tenure: '12 сар',
          yield: '18.2%',
          totalAmount: '420 сая',
          onBuyPressed: () {},
        ),
        Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
        BondMarketCard(
          title: 'MIK',
          subtitle: 'МИК',
          status: l10n.foreign,
          tenure: '8 сар',
          yield: '11.6%',
          totalAmount: '\$500 мянга',
          progress: 0.25,
          progressLabel: '100,000\$ / 500,000\$',
          onBuyPressed: () {},
        ),
      ],
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
        MyBondCard(
          title: 'Net Capital',
          subtitle: 'Нэт Капитал',
          status: l10n.closed,
          statusBgColor: extendedColors.bgSecondary,
          statusTextColor: extendedColors.neutral100,
          ownedAmount: '10,000,000₮',
          interestRate: '21%',
          onSellPressed: () => Navigator.pushNamed(context, '/bond_sell'),
        ),
        MyBondCard(
          title: 'Simple',
          subtitle: 'Симпл',
          status: l10n.open,
          statusBgColor: extendedColors.primary100,
          statusTextColor: extendedColors.primaryMain,
          ownedAmount: '5,000,000₮',
          interestRate: '20%',
          onSellPressed: () => Navigator.pushNamed(context, '/bond_sell'),
        ),
        MyBondCard(
          title: 'MIK',
          subtitle: 'МИК',
          status: l10n.foreign,
          statusBgColor: extendedColors.bgSecondary,
          statusTextColor: extendedColors.neutral100,
          ownedAmount: '3,000\$',
          interestRate: '11.6%',
          onSellPressed: () => Navigator.pushNamed(context, '/bond_sell'),
        ),
      ],
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
          style: theme.textTheme.headlineSmall?.copyWith(
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
