import 'package:flutter/material.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<String> filters = [l10n.all, l10n.ipo, l10n.gainers, l10n.losers, l10n.market];

    _selectedFilter ??= l10n.all;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.book, color: colorScheme.onSurface),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: Icon(Icons.person_outline, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
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
                    hintText: l10n.searchByName,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
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
                  color: theme.primaryColor.withOpacity(0.12),
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
                            l10n.dividendPortfolio,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 24,
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
                            l10n.recommendedStocks,
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            label: l10n.viewPortfolio,
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Horizontal Filters
              FilterChipBar(
                filters: filters,
                selectedFilter: _selectedFilter!,
                onFilterSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected;
                  });
                },
                horizontalPadding: 0,
              ),
              const SizedBox(height: 24),
              // List Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.stock, 
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    l10n.lastPrice24h, 
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Divider(height: 32),
              // Stock List
              const StockPriceRow(
                symbol: 'MNDL',
                name: 'Мандал даатгал ХК',
                price: '65.62₮',
                change: '9.72%',
                isGrowing: true,
              ),
              const StockPriceRow(
                symbol: 'APU',
                name: 'АПУ ХХК',
                price: '957.01₮',
                change: '0.24%',
                isGrowing: false,
              ),
              const StockPriceRow(
                symbol: 'GLMT',
                name: 'Голомт банк',
                price: '1,124.00₮',
                change: '0.00%',
              ),
              const StockPriceRow(
                symbol: 'KHAN',
                name: 'Хаан банк',
                price: '1,348.24₮',
                change: '4.02%',
                isGrowing: false,
              ),
              const StockPriceRow(
                symbol: 'LEND',
                name: 'Lend mn',
                price: '170.00₮',
                change: '3.43%',
                isGrowing: false,
              ),
              const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
