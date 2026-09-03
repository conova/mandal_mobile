import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../common/stock_row_format.dart';
import '../models/market_instrument.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';
import '../widgets/empty_state.dart';
import '../widgets/custom_button.dart';

/// Хувьцааны жагсаалтын дэлгэц:
///   • IPO карусель (олон нийтэд анх удаа зарагдаж буй хувьцаанууд)
///   • ТОП өсөлт / ТОП бууралт картууд
///   • Ангилал тус бүрээр (STOCKGRP) 3 баганат grid жагсаалт
///   • Нэрээр хайх (API search)
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<MarketInstrument> _stocks = [];
  List<MarketInstrument> _ipoStocks = [];
  MarketInstrument? _topGainer;
  MarketInstrument? _topLoser;

  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  /// Хайлтын илэрц (хайлтын горимд л ашиглана)
  List<MarketInstrument> _searchResults = [];
  bool _isSearching = false;

  final PageController _ipoPageController =
      PageController(viewportFraction: 0.92);
  int _ipoPage = 0;

  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final q = _searchController.text.trim();
      if (q != _searchQuery) {
        setState(() => _searchQuery = q);
        _debounce?.cancel();
        if (q.isEmpty) return;
        // 350ms-ийн дараа API дуудна
        _debounce = Timer(const Duration(milliseconds: 350), _search);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _ipoPageController.dispose();
    super.dispose();
  }

  /// Үндсэн дата — жагсаалт, IPO, өсөлт/бууралтыг зэрэг татна
  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthService>();
      // Туслах хэсгүүдийн (IPO, өсөлт/бууралт) endpoint алдаа өгвөл
      // үндсэн жагсаалтыг унагаахгүйгээр хоосон үлдээнэ
      Future<List<Map<String, dynamic>>> safe(
        Future<List<Map<String, dynamic>>> f,
      ) =>
          f.catchError((_) => <Map<String, dynamic>>[]);

      final results = await Future.wait([
        auth.getAvailableStocks(),
        safe(auth.getIpoStocks()),
        safe(auth.getGainers()),
        safe(auth.getLosers()),
      ]);
      if (!mounted) return;

      final gainers = MarketInstrument.listFromJson(results[2]);
      final losers = MarketInstrument.listFromJson(results[3]);
      final ipo = MarketInstrument.listFromJson(results[1]);
      setState(() {
        _stocks = MarketInstrument.listFromJson(results[0]);
        // IPO API хоосон бол dev preview-д mock fallback харуулна.
        // Backend IPO дататай болмогц энэ branch ажиллахгүй.
        //_ipoStocks = ipo.isNotEmpty ? ipo : _mockIpoStocks();
        _ipoStocks = ipo;
        _topGainer = gainers.isNotEmpty ? gainers.first : null;
        _topLoser = losers.isNotEmpty ? losers.first : null;
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

  /// Dev preview-ийн mock IPO мөрүүд — API хоосон үед каруселийг
  /// харуулахад ашиглана
  // List<MarketInstrument> _mockIpoStocks() {
  //   return MarketInstrument.listFromJson(const [
  //     {
  //       'SYMBOL': 'AAA',
  //       'STOCKNAME': 'FullName',
  //       'STOCKCODE': '',
  //       'CLOSEPRICE': 1000,
  //       'BEGDATE': '2026-08-15',
  //       'ENDDATE': '2026-08-20',
  //     },
  //     {
  //       'SYMBOL': 'BBB',
  //       'STOCKNAME': 'Demo Company',
  //       'STOCKCODE': '',
  //       'CLOSEPRICE': 2500,
  //       'BEGDATE': '2026-09-01',
  //       'ENDDATE': '2026-09-10',
  //     },
  //     {
  //       'SYMBOL': 'CCC',
  //       'STOCKNAME': 'Sample JSC',
  //       'STOCKCODE': '',
  //       'CLOSEPRICE': 500,
  //       'BEGDATE': '2026-09-05',
  //       'ENDDATE': '2026-09-12',
  //     },
  //   ]);
  // }

  Future<void> _search() async {
    if (_searchQuery.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final list =
          await context.read<AuthService>().searchStocks(_searchQuery);
      if (!mounted) return;
      setState(() {
        _searchResults = MarketInstrument.listFromJson(list);
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      CustomSnackbar.showError(context, e);
    }
  }

  /// Зах зээл (market) бүрийн хувьцаанууд — MARKETNAME-ээр бүлэглэнэ,
  /// нэргүй мөрүүд "Бусад" бүлэгт орно
  Map<String, List<MarketInstrument>> get _grouped {
    final map = <String, List<MarketInstrument>>{};
    for (final s in _stocks) {
      final key = s.marketName.trim().isNotEmpty
          ? s.marketName.trim()
          : (s.market.trim().isNotEmpty ? s.market.trim() : 'Бусад');
      map.putIfAbsent(key, () => []).add(s);
    }
    // "Бусад" бүлгийг төгсгөлд, бусдыг нэрээр эрэмбэлнэ
    return Map.fromEntries(
      map.entries.toList()
        ..sort((a, b) {
          if (a.key == 'Бусад') return 1;
          if (b.key == 'Бусад') return -1;
          return b.key.compareTo(a.key);
        }),
    );
  }

  void _openDetail(MarketInstrument row) {
    final priceStr = row.closePrice == null
        ? row.stockPrice == null
          ? '-'
          : formatStockAmount(row.stockPrice, decimals: 2)
        : formatStockAmount(row.closePrice, decimals: 2);
    final pct = row.priceChange;
    Navigator.pushNamed(
      context,
      '/stock_detail',
      arguments: {
        'symbol': row.symbol,
        'name': row.name,
        'price': priceStr,
        'change': pct != null ? '${pct.abs().toStringAsFixed(2)}%' : '-',
        'isGrowing': pct == null ? null : pct >= 0,
        'stockcode': row.stockcode,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: extendedColors.bgBase,
            boxShadow: _isScrolled
                ? [
                    BoxShadow(
                      color: extendedColors.neutral500.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            toolbarHeight: 64,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchBar(l10n, theme, extendedColors),
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final bool scrolled = notification.metrics.pixels > 0;
          if (scrolled != _isScrolled) {
            setState(() => _isScrolled = scrolled);
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _fetchAll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (_searchQuery.isNotEmpty)
                ..._buildSearchSlivers(l10n, theme, extendedColors)
              else if (_isLoading)
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
              else ...[
                if (_ipoStocks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildIpoCarousel(l10n, theme, extendedColors),
                  ),
                if (_topGainer != null || _topLoser != null)
                  SliverToBoxAdapter(
                    child: _buildTopMovers(l10n, theme, extendedColors),
                  ),
                ..._buildGroupSlivers(theme, extendedColors),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    AppLocalizations l10n,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchByName,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral200,
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
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  // ─── IPO карусель ───

  Widget _buildIpoCarousel(
    AppLocalizations l10n,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [extendedColors.primary200, extendedColors.bgBase],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ipo,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.ipoSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _ipoPageController,
              itemCount: _ipoStocks.length,
              onPageChanged: (i) => setState(() => _ipoPage = i),
              itemBuilder: (context, i) =>
                  _buildIpoCard(_ipoStocks[i], l10n, theme, extendedColors),
            ),
          ),
          if (_ipoStocks.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_ipoStocks.length, (i) {
                final active = i == _ipoPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? extendedColors.neutral100
                        : extendedColors.neutral400,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  /// IPO хугацаа — raw мөрөөс эхлэх/дуусах огноог олж "2026/08/15 – 2026/08/20"
  /// хэлбэрээр буцаана.
  String _ipoPeriod(MarketInstrument row) {
    String fmt(dynamic raw) {
      final d = parseStockDate(raw);
      if (d == null) return '';
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(d.month)}/${two(d.day)}';
    }

    final sFmt = fmt(row.orderBeginDate);
    final eFmt = fmt(row.orderEndDate);

    if (sFmt.isEmpty && eFmt.isEmpty) return '-';
    if (sFmt.isNotEmpty && eFmt.isNotEmpty) return '$sFmt – $eFmt';
    return sFmt.isNotEmpty ? sFmt : eFmt;
  }

  Widget _buildIpoCard(
    MarketInstrument row,
    AppLocalizations l10n,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final price = row.stockPrice == null
        ? row.closePrice == null
          ? '-'
          : formatStockAmount(row.closePrice, decimals: 2)
        : formatStockAmount(row.stockPrice, decimals: 2);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 6, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          row.symbol,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: extendedColors.neutral100,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            row.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: extendedColors.neutral200,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.ipo,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CustomButton(
                label: l10n.subscribe,
                size: CustomButtonSize.small,
                onPressed: () => _openDetail(row),
                minWidth: 90,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l10n.term,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _ipoPeriod(row),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: extendedColors.neutral500),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l10n.unitStockPrice,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── ТОП өсөлт / бууралт ───

  Widget _buildTopMovers(
    AppLocalizations l10n,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    Widget card(String label, MarketInstrument? row, bool isGain) {
      if (row == null) return const SizedBox.shrink();
      final pct = row.priceChange ?? 0;
      final color = isGain ? extendedColors.primaryMain : extendedColors.red;
      return Expanded(
        child: GestureDetector(
          onTap: () => _openDetail(row),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isGain
                  ? extendedColors.primary100
                  : extendedColors.red100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        row.symbol,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    Text(
                      '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          card(l10n.topGainer, _topGainer, true),
          const SizedBox(width: 12),
          card(l10n.topLoser, _topLoser, false),
        ],
      ),
    );
  }

  // ─── Ангиллын grid ───

  List<Widget> _buildGroupSlivers(
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final slivers = <Widget>[];
    _grouped.forEach((title, rows) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _buildStockTile(rows[i], theme, extendedColors),
              childCount: rows.length,
            ),
          ),
        ),
      );
    });
    return slivers;
  }

  Widget _buildStockTile(
    MarketInstrument row,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final pct = row.priceChange ?? 0;
    final isUp = pct > 0;
    final isDown = pct < 0;

    final price = row.closePrice == null
        ? '-'
        : formatStockAmount(row.closePrice, decimals: 2);

    // Өмнөх ханш (нээлт) болон абсолют өөрчлөлт
    final open = row.openPrice;
    final close = row.closePrice;
    final delta = (open != null && close != null) ? close - open : null;

    final bg = isUp
        ? extendedColors.primary100
        : isDown
          ? extendedColors.red100
          : extendedColors.bgSecondary;

    final pctColor = isUp
        ? extendedColors.primaryMain
        : isDown
          ? extendedColors.red
          : extendedColors.neutral300;

    final deltaStr = delta == null
        ? ''
        : '${delta >= 0 ? '+' : '-'}${formatNumbers(delta.abs(), decimals: delta.abs() < 10 ? 2 : 0)}';

    return GestureDetector(
      onTap: () => _openDetail(row),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                Text(
                  '${pct > 0 ? '+' : ''}${pct.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: pctColor,
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                price,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                ),
              ),
            ),
             const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    open == null
                        ? '-'
                        : formatStockAmount(open, decimals: 2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                Text(
                  deltaStr,
                  style: AppTextStyles.caption.copyWith(color: pctColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Хайлтын горим ───

  List<Widget> _buildSearchSlivers(
    AppLocalizations l10n,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    if (_isSearching) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_searchResults.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmptyState(
                icon: 'search-icon',
                title: l10n.noResults,
                hint: l10n.noResultsHint,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            l10n.resultsCount(_searchResults.length.toString()),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => _buildStockTile(
              _searchResults[i],
              theme,
              extendedColors,
            ),
            childCount: _searchResults.length,
          ),
        ),
      ),
    ];
  }
}
