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
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
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
                    const SizedBox(height: 8),
                    // Promo Banner
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            extendedColors.primary100,
                            extendedColors.bgBase,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Briefcase image — banner-ийн top-right-д тогтсон
                          Positioned(
                            top: -12,
                            right: -16,
                            child: SizedBox(
                              width: 99,
                              height: 128,
                              child: Image.asset(
                                'assets/images/briefcase.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Текстийн контент — image-аас зайтай үлдэхийн тулд
                          // баруун padding 128 болгосон
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 100, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  locale.dividendPortfolio,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 28,
                                        height: 1.1,
                                        color: extendedColors.neutral100,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 48,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  locale.recommendedStocks,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: extendedColors.neutral200,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 120,
                                  child: CustomButton(
                                    label: locale.viewPortfolio,
                                    onPressed: () {},
                                    size: CustomButtonSize.small,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky FilterChipBar + List Headers
            SliverAppBar(
              pinned: true,
              floating: false,
              automaticallyImplyLeading: false,
              surfaceTintColor: extendedColors.bgBase,
              elevation: 0,
              toolbarHeight: 52,
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Container(
                  color: extendedColors.bgBase,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locale.stock,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        locale.lastPrice24h,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Scrollable Stock List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
