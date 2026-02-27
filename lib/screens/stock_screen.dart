import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/stock_price_row.dart';
import '../widgets/custom_button.dart';

import '../widgets/filter_chip_bar.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>();

    if (locale == null || extendedColors == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<String> filters = [
      locale.all,
      locale.ipo,
      locale.gainers,
      locale.losers,
      locale.market,
    ];

    _selectedFilter ??= locale.all;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: CustomScrollView(
        slivers: [
          // Scrollable Search Bar and Promo Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: locale.searchByName,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: theme.disabledColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Promo Banner
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale.dividendPortfolio,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                locale.recommendedStocks,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                label: locale.viewPortfolio,
                                onPressed: () {},
                                size: CustomButtonSize.small,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Image.asset(
                            'assets/images/briefcase.png',
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.account_balance_wallet,
                              size: 80,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // Sticky FilterChipBar
          SliverAppBar(
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            backgroundColor: extendedColors.bgBase,
            surfaceTintColor: extendedColors.bgBase,
            elevation: 0,
            toolbarHeight: 60,
            titleSpacing: 0,
            title: FilterChipBar(
              filters: filters,
              selectedFilter: _selectedFilter!,
              onFilterSelected: (selected) {
                setState(() {
                  _selectedFilter = selected;
                });
              },
              horizontalPadding: 16,
            ),
          ),
          // Scrollable Stock List Header and Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                // List Headers
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locale.stock,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 40), // Spacer for narrow screens
                      Text(
                        locale.lastPrice24h,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                // Stock List
                StockPriceRow(
                  symbol: 'MNDL',
                  name: 'Мандал даатгал ХК',
                  price: '65.62₮',
                  change: '9.72%',
                  isGrowing: true,
                  onTap: () => Navigator.pushNamed(context, '/stock_detail'),
                ),
                StockPriceRow(
                  symbol: 'APU',
                  name: 'АПУ ХХК',
                  price: '957.01₮',
                  change: '0.24%',
                  isGrowing: false,
                  onTap: () => Navigator.pushNamed(context, '/stock_detail'),
                ),
                StockPriceRow(
                  symbol: 'GLMT',
                  name: 'Голомт банк',
                  price: '1,124.00₮',
                  change: '0.00%',
                  onTap: () => Navigator.pushNamed(context, '/stock_detail'),
                ),
                StockPriceRow(
                  symbol: 'KHAN',
                  name: 'Хаан банк',
                  price: '1,348.24₮',
                  change: '4.02%',
                  isGrowing: false,
                  onTap: () => Navigator.pushNamed(context, '/stock_detail'),
                ),
                StockPriceRow(
                  symbol: 'LEND',
                  name: 'Lend mn',
                  price: '170.00₮',
                  change: '3.43%',
                  isGrowing: false,
                  onTap: () => Navigator.pushNamed(context, '/stock_detail'),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
