import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/circle_back_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/empty_state.dart';

/// API row — stock list-тэй ижил бүтэцтэй:
/// { STOCKCODE, SYMBOL, STOCKNAME, COMPNAME, CLOSEPRICE, OPENPRICE,
///   PRICECHANGE, STOCKTYPE, TYPENAME, BOARDNAME, ISOPEN, ISFOREIGN, ... }
class WatchlistStock {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool? isPositive;

  /// /stocks/info дуудахад хэрэглэгдэнэ (STOCKCODE)
  final String stockcode;

  const WatchlistStock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    this.isPositive,
    this.stockcode = '',
  });

  factory WatchlistStock.fromApi(Map<String, dynamic> row) {
    final closePrice = row['CLOSEPRICE'];
    final priceChange = row['PRICECHANGE'];
    final isForeign = row['ISFOREIGN']?.toString() == '1';

    final priceStr = closePrice == null
        ? '-'
        : '${_formatNumber(closePrice.toString())}${isForeign ? r'$' : '₮'}';

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
      stockcode: (row['STOCKCODE'] ?? row['SYMBOL'])?.toString() ?? '',
      symbol: row['SYMBOL']?.toString() ?? '',
      name: (row['STOCKNAME'] ?? row['COMPNAME'])?.toString() ?? '',
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

  /// Хувьцааг хасахын өмнө баталгаажуулах + сервэрт хүсэлт илгээх.
  /// `true` бол Dismissible элементийг устгана, `false` бол буцаана.
  Future<bool> _confirmRemove(
    WatchlistStock item,
    ExtendedColors c,
  ) async {
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${item.symbol} устгах'),
        backgroundColor: extendedColors.bgBase,

        content: Text(
          '${item.name} хувьцааг хадгалсан жагсаалтаас хасах уу?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Болих'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: c.red),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      final auth = context.read<AuthService>();
      await auth.removeFromWatchlist(item.symbol);
      // Локал state-ээс хасч, шинэ дарааллыг хадгална
      if (!mounted) return true;
      setState(() {
        _watchlistItems.removeWhere((s) => s.symbol == item.symbol);
      });
      final symbols = _watchlistItems.map((s) => s.symbol).toList();
      await auth.saveWatchlistOrder(symbols);
      if (!mounted) return true;
      CustomSnackbar.show(context, message: '${item.symbol} устгагдлаа');
      // Серверээс жагсаалтыг дахин татаж баталгаажуулна
      _fetchWatchlist();
      return true;
    } catch (e) {
      if (!mounted) return false;
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
      return false;
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
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleBackButton(),
                  GestureDetector(
                    onTap: _openAddScreen,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: extendedColors.primaryMain,
                        shape: BoxShape.circle,
                      ),
                      child: const CustomSvgIcon(
                        'plus',
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Image.asset('assets/images/bookmark.png', width: 80, height: 80),
          const SizedBox(height: 16),
          Text(
            l10n.saved,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_watchlistItems.length} ${l10n.pieceOfStock}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: extendedColors.neutral500, height: 1),
          const SizedBox(height: 16),
          if (_watchlistItems.isEmpty)
            // Хоосон төлөв — дундын EmptyState component
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: EmptyState(
                icon: Icons.star_border,
                title: AppLocalizations.of(context)!.emptyWatchlist,
                hint: AppLocalizations.of(context)!.emptyWatchlistHint,
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
                      l10n.stock,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                  ),
                  Text(
                    l10n.lastPrice24h,
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
                final key = ValueKey('${item.symbol}_$index');
                return Dismissible(
                  key: key,
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: extendedColors.red.withOpacity(0.1),
                    child: Icon(
                      Icons.delete_outline,
                      color: extendedColors.red,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (_) async {
                    return await _confirmRemove(item, extendedColors);
                  },
                  child: _buildWatchlistItem(
                    key: const ValueKey('inner'),
                    item: item,
                    extendedColors: extendedColors,
                    theme: theme,
                  ),
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
        : (item.isPositive! ? 'button-up' : 'button-down');
    final changeColor = item.isPositive == null
        ? extendedColors.neutral200
        : (item.isPositive! ? extendedColors.primaryMain : extendedColors.red);

    return Material(
      key: key,
      color: extendedColors.bgBase,
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            '/stock_detail',
            arguments: {
              'symbol': item.symbol,
              'name': item.name,
              'price': item.price,
              'change': item.change,
              'isGrowing': item.isPositive,
              'stockcode': item.stockcode,
            },
          );
          // Detail дээр одоор нэмж/хассан байж болзошгүй тул шинэчилнэ
          if (mounted) _fetchWatchlist();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              CustomSvgIcon('menu-item', color: extendedColors.neutral300, size: 24),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (changePrefix != '')
                      CustomSvgIcon(
                        changePrefix,
                        color: changeColor,
                        size: 6,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      item.change,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
