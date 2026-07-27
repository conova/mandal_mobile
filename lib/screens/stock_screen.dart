import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../common/stock_row_format.dart';
import '../models/market_instrument.dart';
import '../services/auth_service.dart';
import '../widgets/custom_svg_icon.dart';
import '../widgets/stock_price_row.dart';
import '../widgets/custom_button.dart';

import '../widgets/empty_state.dart';
import '../widgets/filter_chip_bar.dart';

/// Filter category-уудтай харгалзах API endpoint-ийн ID
enum _StockFilter { all, ipo, gainers, losers, market, orderActive }

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String? _selectedFilter;
  _StockFilter _activeFilter = _StockFilter.all;
  List<MarketInstrument> _stocks = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final q = _searchController.text.trim();
      if (q != _searchQuery) {
        // setState — banner/tag-ууд бичих мөчид шууд нуугдаж/сэргэнэ
        setState(() => _searchQuery = q);
        _debounce?.cancel();
        // 350ms-ийн дараа API дуудна
        _debounce = Timer(const Duration(milliseconds: 350), _fetch);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Хайлт оруулсан тохиолдолд API хариу шууд орно
  List<MarketInstrument> get _filteredStocks => _stocks;

  /// Идэвхтэй filter-ийг search API-руу type болгож шилжүүлэх
  String? _typeForActiveFilter() {
    switch (_activeFilter) {
      case _StockFilter.gainers:
        return 'gainers';
      case _StockFilter.losers:
        return 'losers';
      case _StockFilter.ipo:
        return 'ipo';
      case _StockFilter.orderActive:
        return 'orderActive';
      case _StockFilter.all:
      case _StockFilter.market:
        return null;
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthService>();
      List<Map<String, dynamic>> list;

      if (_searchQuery.isNotEmpty) {
        // Хайлт идэвхтэй → /stocks/search
        list = await auth.searchStocks(
          _searchQuery,
          type: _typeForActiveFilter(),
        );
      } else {
        list = await switch (_activeFilter) {
          _StockFilter.ipo => auth.getIpoStocks(),
          _StockFilter.gainers => auth.getGainers(),
          _StockFilter.losers => auth.getLosers(),
          _StockFilter.orderActive => auth.getAvailableStocks(),
          _StockFilter.all || _StockFilter.market => auth.getAvailableStocks(),
        };
      }

      if (!mounted) return;
      setState(() {
        _stocks = MarketInstrument.listFromJson(list);
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
    if (selected == locale.ipo) {
      next = _StockFilter.ipo;
    } else if (selected == locale.gainers)
      next = _StockFilter.gainers;
    else if (selected == locale.losers)
      next = _StockFilter.losers;
    else if (selected == locale.market)
      next = _StockFilter.market;

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
      locale.orderActive,
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Search Bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
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
                          icon: CustomSvgIcon('search-icon', color: extendedColors.neutral100),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: CustomSvgIcon(
                                    'x-icon',
                                    size: 24,
                                    color: extendedColors.neutral100,
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
                    // Promo Banner — хайлтын горимд нуугдана
                    if (_searchQuery.isEmpty)
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
                              right: -36,
                              child: SizedBox(
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
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                24,
                                100,
                                16,
                              ),
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
                                    width: 32,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
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
            // Sticky FilterChipBar + List Headers — хайлтын горимд оронд нь
            // илэрцийн тоог харуулна
            if (_searchQuery.isEmpty)
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
              )
            else if (!_isLoading &&
                _error == null &&
                _filteredStocks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text(
                    locale.resultsCount(_filteredStocks.length.toString()),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
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
                child: _searchQuery.isEmpty
                    ? Center(
                        child: Text(
                          locale.noData,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral300,
                          ),
                        ),
                      )
                    // Хайлтад илэрц олдоогүй — дундын EmptyState component
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EmptyState(
                            icon: 'search-icon',
                            title: locale.noResults,
                            hint: locale.noResultsHint,
                          ),
                          // Дээшээ бага зэрэг төвлөрүүлнэ
                          const SizedBox(height: 120),
                        ],
                      ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 55),
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

  Widget _buildRow(MarketInstrument row, BuildContext context) {
    final priceStr = row.closePrice == null
        ? '-'
        : formatStockAmount(row.closePrice, decimals: 0);

    String changeStr = '-';
    bool? isGrowing;
    final pct = row.priceChange;
    if (pct != null) {
      changeStr = '${pct.abs().toStringAsFixed(2)}%';
      if (pct > 0) isGrowing = true;
      if (pct < 0) isGrowing = false;
    }

    return StockPriceRow(
      symbol: row.symbol,
      name: row.name,
      price: priceStr,
      change: changeStr,
      isGrowing: isGrowing,
      onTap: () => Navigator.pushNamed(
        context,
        '/stock_detail',
        arguments: {
          'symbol': row.symbol,
          'name': row.name,
          'price': priceStr,
          'change': changeStr,
          'isGrowing': isGrowing,
          'stockcode': row.stockcode,
        },
      ),
    );
  }
}
