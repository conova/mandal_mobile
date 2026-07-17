import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../models/market_instrument.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_snackbar.dart';
import 'components/stock_detail/stock_detail_header.dart';
import 'components/stock_detail/stock_detail_chart.dart';
import 'components/stock_detail/stock_detail_general_info.dart';
import 'components/stock_detail/stock_detail_dividend_history.dart';
import 'components/stock_detail/stock_detail_bottom_bar.dart';

/// Route args:
///   { symbol: String, name: String, price: String, change: String,
///     isGrowing: bool?, stockcode: String? }
///
/// Дэлгэц нээгдэхэд /stocks/info API-г stockcode-оор дуудаж дэлгэрэнгүй
/// мэдээллийг татна.
class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  Map<String, dynamic> _args = const {};
  bool _initialized = false;

  /// /stocks/info-ийн мөрүүд. Эхний мөр = одоогийн ерөнхий мэдээлэл,
  /// мөр бүрийн divAmount/divDate = ногдол ашгийн түүх.
  List<MarketInstrument> _infoRows = const [];

  MarketInstrument? get _info => _infoRows.isEmpty ? null : _infoRows.first;

  /// Watchlist-д байгаа эсэх (null — хараахан шалгаагүй)
  bool _inWatchlist = false;
  bool _watchlistBusy = false;

  /// Арилжааны Авах/Зарах цэс нээлттэй эсэх
  bool _tradeMenuOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    _fetchInfo();
    _checkWatchlist();
  }

  String get _symbol => (_args['symbol'] as String?) ?? _info?.symbol ?? '';

  /// Энэ хувьцаа watchlist-д байгаа эсэхийг шалгана
  Future<void> _checkWatchlist() async {
    if (_symbol.isEmpty) return;
    try {
      final list = await context.read<AuthService>().getWatchlist();
      if (!mounted) return;
      setState(() {
        _inWatchlist =
            list.any((row) => row['SYMBOL']?.toString() == _symbol);
      });
    } catch (e) {
      // Хоосон одоор үлдээгээд алдааг мэдэгдэнэ
      if (!mounted) return;
      CustomSnackbar.showError(context, e);
    }
  }

  /// Од дарахад — watchlist-д нэмэх / хасах
  Future<void> _toggleWatchlist() async {
    if (_watchlistBusy || _symbol.isEmpty) return;
    setState(() => _watchlistBusy = true);
    try {
      final auth = context.read<AuthService>();
      final message = _inWatchlist
          ? await auth.removeFromWatchlist(_symbol)
          : await auth.addToWatchlist(_symbol);
      if (!mounted) return;
      setState(() {
        _inWatchlist = !_inWatchlist;
        _watchlistBusy = false;
      });
      CustomSnackbar.show(context, message: message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _watchlistBusy = false);
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
    }
  }

  Future<void> _fetchInfo() async {
    final stockcode = _args['stockcode']?.toString() ?? '';
    if (stockcode.isEmpty) return;
    try {
      final rows = await context.read<AuthService>().getStockInfo(stockcode);
      if (!mounted || rows.isEmpty) return;
      setState(() => _infoRows = MarketInstrument.listFromJson(rows));
    } catch (e) {
      // Args-аар ирсэн утгуудаа харуулсаар байх ч алдааг мэдэгдэнэ
      if (!mounted) return;
      CustomSnackbar.showError(context, e);
    }
  }

  /// Бүх мөрийн divDate/divAmount-аас ногдол ашгийн түүх угсарна
  List<Map<String, String>> get _dividendHistory {
    final items = <Map<String, String>>[];
    for (final row in _infoRows) {
      final date = parseStockDate(row.divDate);
      if (date == null || row.divAmount == null) continue;
      items.add({
        'year': date.year.toString(),
        'amount': formatStockAmount(row.divAmount, decimals: 0),
      });
    }
    return items;
  }

  /// info-гийн утга байвал түүнийг, үгүй бол args-ийн утгыг ашиглана
  String _display(String argKey, String? infoValue, String fallback) {
    if (infoValue != null && infoValue.isNotEmpty) return infoValue;
    return (_args[argKey] as String?) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final symbol = _display('symbol', _info?.symbol, '');
    final name = _display('name', _info?.name, '');

    // Ханш/өөрчлөлт — info-гоос тоо ирвэл форматлана, үгүй бол args
    final infoPrice = _info?.closePrice;
    final price = infoPrice != null
        ? formatStockAmount(infoPrice, decimals: 0)
        : (_args['price'] as String?) ?? '-';

    final infoChange = _info?.priceChange;
    final change = infoChange != null
        ? '${infoChange.abs().toStringAsFixed(2)}%'
        : (_args['change'] as String?) ?? '-';
    final isGrowing =
        infoChange != null ? infoChange >= 0 : _args['isGrowing'] as bool?;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _inWatchlist ? Icons.star : Icons.star_border,
              color: _inWatchlist
                  ? theme.extension<ExtendedColors>()!.yellow
                  : theme.colorScheme.onSurface,
            ),
            onPressed: _watchlistBusy ? null : _toggleWatchlist,
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StockDetailHeader(
                  symbol: symbol,
                  name: name,
                  price: price,
                  change: change,
                  isGrowing: isGrowing,
                ),
                const SizedBox(height: 32),
                StockDetailChart(symbol: symbol),
                const SizedBox(height: 32),
                // Эхний мөрийн мэдээллээр ерөнхий мэдээллийг бөглөнө
                StockDetailGeneralInfo(
                  marketCap: _info?.marketValue == null
                      ? '-'
                      : '₮${formatCompactAmount(_info!.marketValue)}',
                  avgVolume: _info?.avgTrade == null
                      ? '-'
                      : '₮${formatCompactAmount(_info!.avgTrade)}',
                  dailyVolume: _info?.dayTrade == null
                      ? '-'
                      : '₮${formatCompactAmount(_info!.dayTrade)}',
                  peRatio: _info?.peRatio?.toString() ?? '-',
                  pbRatio: _info?.pbRatio?.toString() ?? '-',
                  dividendYield:
                      _info?.divYield == null ? '-' : '${_info!.divYield}%',
                ),
                const SizedBox(height: 48),
                // Бүх мөрийн DIVAMOUNT/DIVDATE = өнгөрсөн ногдол ашгууд
                StockDetailDividendHistory(items: _dividendHistory),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Арилжааны цэс нээлттэй үед: бүдгэрүүлэлт + Авах/Зарах товчнууд
          if (_tradeMenuOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _tradeMenuOpen = false),
                child: Container(color: Colors.black38),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildTradeMenuButton(
                    label: AppLocalizations.of(context)!.buy,
                    color: theme.extension<ExtendedColors>()!.primaryMain,
                    onPressed: () => _openTrading('buy'),
                  ),
                  const SizedBox(height: 16),
                  _buildTradeMenuButton(
                    label: AppLocalizations.of(context)!.sell,
                    color: theme.extension<ExtendedColors>()!.red,
                    onPressed: () => _openTrading('sell'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: StockDetailBottomBar(
        isMenuOpen: _tradeMenuOpen,
        onTrade: () => setState(() => _tradeMenuOpen = !_tradeMenuOpen),
      ),
    );
  }

  /// Авах / Зарах pill товч (арилжааны цэс)
  Widget _buildTradeMenuButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      height: 52,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  /// Арилжааны дэлгэц рүү авах/зарах талтай нь шилжинэ
  void _openTrading(String side) {
    setState(() => _tradeMenuOpen = false);
    Navigator.pushNamed(
      context,
      '/stock_trading',
      arguments: {
        ..._args,
        if (_info != null) 'info': _info!.raw,
        'side': side,
      },
    );
  }
}
