import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';

/// API row: { TAGID, SYMBOL, STOCKNAME, CLOSEPRICE, OPENPRICE, PRICECHANGE,
///            STOCKTYPE, TYPENAME, BOARDNAME }
class WatchlistStock {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool? isPositive;

  const WatchlistStock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    this.isPositive,
  });

  factory WatchlistStock.fromApi(Map<String, dynamic> row) {
    final closePrice = row['CLOSEPRICE'];
    final priceChange = row['PRICECHANGE'];

    final priceStr = closePrice == null
        ? '-'
        : '${_formatNumber(closePrice.toString())}₮';

    String changeStr = '-';
    bool? positive;
    if (priceChange != null) {
      final pct = double.tryParse(priceChange.toString()) ?? 0;
      changeStr = '${pct.abs().toStringAsFixed(2)}%';
      if (pct > 0) {
        positive = true;
      } else if (pct < 0) {
        positive = false;
      } else {
        positive = null;
      }
    }

    return WatchlistStock(
      symbol: row['SYMBOL']?.toString() ?? '',
      name: row['STOCKNAME']?.toString() ?? '',
      price: priceStr,
      change: changeStr,
      isPositive: positive,
    );
  }

  static String _formatNumber(String s) {
    final n = num.tryParse(s);
    if (n == null) return s;
    return n
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

class WatchlistDetailScreen extends StatefulWidget {
  const WatchlistDetailScreen({super.key});

  @override
  State<WatchlistDetailScreen> createState() => _WatchlistDetailScreenState();
}

class _WatchlistDetailScreenState extends State<WatchlistDetailScreen> {
  List<WatchlistStock> _watchlistItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  Future<void> _fetchWatchlist() async {
    try {
      final auth = context.read<AuthService>();
      final list = await auth.getWatchlist();
      if (!mounted) return;
      setState(() {
        _watchlistItems = list.map(WatchlistStock.fromApi).toList();
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.pushNamed(context, '/add_watchlist');
    if (result == true) {
      await _fetchWatchlist();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: extendedColors.neutral100,
                      size: 24,
                    ),
                  ),
                  GestureDetector(
                    onTap: _openAddScreen,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: extendedColors.primaryMain,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchWatchlist,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildErrorState(theme, extendedColors)
                        : _buildContent(theme, extendedColors),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ExtendedColors c) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          _error ?? '',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: c.neutral200),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, ExtendedColors extendedColors) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: extendedColors.neutral100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.bookmark_outline,
              color: extendedColors.primaryMain,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Хадгалсан',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_watchlistItems.length} ширхэг хувьцаа',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: extendedColors.neutral500, height: 1),
          const SizedBox(height: 16),
          if (_watchlistItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Жагсаалт хоосон байна',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral300,
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(
                      'Хувьцаа',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                  ),
                  Text(
                    'Сүүлийн ханш (24 цаг)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final elevation =
                        Tween<double>(begin: 0, end: 4).animate(animation).value;
                    return Material(
                      elevation: elevation,
                      color: extendedColors.bgBase,
                      borderRadius: BorderRadius.circular(8),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemCount: _watchlistItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _watchlistItems.removeAt(oldIndex);
                  _watchlistItems.insert(newIndex, item);
                });
                // Шинэ дарааллыг локалд хадгална
                final symbols =
                    _watchlistItems.map((s) => s.symbol).toList();
                context.read<AuthService>().saveWatchlistOrder(symbols);
              },
              itemBuilder: (context, index) {
                final item = _watchlistItems[index];
                return _buildWatchlistItem(
                  key: ValueKey('${item.symbol}_$index'),
                  item: item,
                  extendedColors: extendedColors,
                  theme: theme,
                );
              },
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWatchlistItem({
    required Key key,
    required WatchlistStock item,
    required ExtendedColors extendedColors,
    required ThemeData theme,
  }) {
    final changePrefix = item.isPositive == null
        ? ''
        : (item.isPositive! ? '▲ ' : '▼ ');
    final changeColor = item.isPositive == null
        ? extendedColors.neutral200
        : (item.isPositive! ? extendedColors.primaryMain : extendedColors.red);

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: extendedColors.bgBase,
      child: Row(
        children: [
          Icon(Icons.drag_handle, color: extendedColors.neutral300, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.symbol,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.price,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$changePrefix${item.change}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
