import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/stock_price_row.dart';
import '../widgets/custom_button.dart';

import '../widgets/filter_chip_bar.dart';

/// Filter category-уудтай харгалзах API endpoint-ийн ID
enum _StockFilter { all, ipo, gainers, losers, market }

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String? _selectedFilter;
  _StockFilter _activeFilter = _StockFilter.all;
  List<Map<String, dynamic>> _stocks = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final q = _searchController.text.trim().toLowerCase();
      if (q != _searchQuery) {
        setState(() => _searchQuery = q);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Хайлтын дүнгээр шүүгдсэн жагсаалт
  List<Map<String, dynamic>> get _filteredStocks {
    if (_searchQuery.isEmpty) return _stocks;
    return _stocks.where((row) {
      final symbol = (row['SYMBOL']?.toString() ?? '').toLowerCase();
      final name =
          ((row['STOCKNAME'] ?? row['COMPNAME'])?.toString() ?? '')
              .toLowerCase();
      return symbol.contains(_searchQuery) || name.contains(_searchQuery);
    }).toList();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthService>();
      final list = await switch (_activeFilter) {
        _StockFilter.ipo => auth.getIpoStocks(),
        _StockFilter.gainers => auth.getGainers(),
        _StockFilter.losers => auth.getLosers(),
        _StockFilter.all || _StockFilter.market =>
          auth.getAvailableStocks(),
      };
      if (!mounted) return;
      setState(() {
        _stocks = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onFilterSelected(String selected, AppLocalizations locale) {
    _StockFilter next = _StockFilter.all;
    if (selected == locale.ipo) next = _StockFilter.ipo;
    else if (selected == locale.gainers) next = _StockFilter.gainers;
    else if (selected == locale.losers) next = _StockFilter.losers;
    else if (selected == locale.market) next = _StockFilter.market;

    if (next != _activeFilter) {
      setState(() {
        _selectedFilter = selected;
        _activeFilter = next;
      });
      _fetch();
    } else {
      setState(() => _selectedFilter = selected);
    }
  }

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
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: locale.searchByName,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: theme.disabledColor),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: theme.disabledColor,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
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
                onFilterSelected: (selected) =>
                    _onFilterSelected(selected, locale),
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
            // Stock List — API-аас dynamic
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                    ),
                  ),
                ),
              )
            else if (_filteredStocks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Жагсаалт хоосон байна'
                        : 'Хайлтад тохирох хувьцаа олдсонгүй',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList.builder(
                  itemCount: _filteredStocks.length,
                  itemBuilder: (context, i) {
                    final row = _filteredStocks[i];
                    return _buildRow(row, context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> row, BuildContext context) {
    final symbol = row['SYMBOL']?.toString() ?? '';
    final name = (row['STOCKNAME'] ?? row['COMPNAME'])?.toString() ?? '';
    final closePrice = row['CLOSEPRICE'];
    final priceChange = row['PRICECHANGE'];

    final priceStr = closePrice == null
        ? '-'
        : '${_formatNumber(closePrice.toString())}₮';

    String changeStr = '-';
    bool? isGrowing;
    if (priceChange != null) {
      final pct = double.tryParse(priceChange.toString()) ?? 0;
      changeStr = '${pct.abs().toStringAsFixed(2)}%';
      if (pct > 0) isGrowing = true;
      else if (pct < 0) isGrowing = false;
    }

    return StockPriceRow(
      symbol: symbol,
      name: name,
      price: priceStr,
      change: changeStr,
      isGrowing: isGrowing,
      onTap: () => Navigator.pushNamed(
        context,
        '/stock_detail',
        arguments: {
          'symbol': symbol,
          'name': name,
          'price': priceStr,
          'change': changeStr,
          'isGrowing': isGrowing,
        },
      ),
    );
  }

  String _formatNumber(String s) {
    final n = num.tryParse(s);
    if (n == null) return s;
    return n.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
