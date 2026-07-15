import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';

class StockPortfolioScreen extends StatefulWidget {
  const StockPortfolioScreen({super.key});

  @override
  State<StockPortfolioScreen> createState() => _StockPortfolioScreenState();
}

class _StockPortfolioScreenState extends State<StockPortfolioScreen> {
  bool _isLoading = true;
  List<_StockHolding> _holdings = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchMyStocks);
  }

  Future<void> _fetchMyStocks() async {
    try {
      final auth = context.read<AuthService>();
      final rows = await auth.getMyStocks();
      if (!mounted) return;
      setState(() {
        _holdings = rows.map(_StockHolding.fromApi).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  static const _historyItems = [
    _StockHistory(
      symbol: 'AARD',
      name: '',
      totalProfit: '50,300,000.20₮',
      realizedProfit: '50,000,000.00₮',
      unrealizedProfit: '0.00₮',
      dividendProfit: '300,000.20₮',
    ),
    _StockHistory(
      symbol: 'KHAN',
      name: 'Хаан банк',
      totalProfit: '5,000,000.20₮',
      realizedProfit: '4,000,000.20₮',
      unrealizedProfit: '1,000,000.00₮',
      dividendProfit: '0.00₮',
    ),
    _StockHistory(
      symbol: 'APU',
      name: 'АПУ ХХК',
      totalProfit: '300,000.00₮',
      realizedProfit: '300,000.00₮',
      unrealizedProfit: '0.00₮',
      dividendProfit: '0.00₮',
    ),
    _StockHistory(
      symbol: 'GLMT',
      name: 'Голомт банк',
      totalProfit: '300,000.00₮',
      realizedProfit: '300,000.00₮',
      unrealizedProfit: '0.00₮',
      dividendProfit: '0.00₮',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, theme, extendedColors, l10n),
            const SizedBox(height: 24),
            // My Stocks section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.myStocks,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Table header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.stocks,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.amountPieces,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.profitPlusMinus,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Stock rows
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_holdings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.noData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                ),
              )
            else
              ..._holdings.map(
                (stock) => _buildStockRow(stock, theme, extendedColors),
              ),
            const SizedBox(height: 16),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 24),
            // History section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.historyAll,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Stock history cards
            ..._historyItems.map(
              (item) => _buildHistoryCard(item, theme, extendedColors, l10n),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: extendedColors.bgSecondary,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: extendedColors.neutral100,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: extendedColors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.pie_chart_outline,
              color: extendedColors.bgBase,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.stocks,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
          const SizedBox(height: 8),
          _buildAmountText('50,000,000.00₮', theme, extendedColors),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAmountText(
    String amount,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final dotIndex = amount.indexOf('.');
    if (dotIndex == -1) {
      return Text(
        amount,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: extendedColors.neutral100,
        ),
      );
    }

    final integerPart = amount.substring(0, dotIndex);
    final decimalPart = amount.substring(dotIndex);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: integerPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          TextSpan(
            text: decimalPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockRow(
    _StockHolding stock,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final profitColor = stock.isPositive
        ? extendedColors.primaryMain
        : extendedColors.red;
    final arrow = stock.isPositive ? '▲' : '▼';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.symbol,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                Text(
                  stock.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: extendedColors.neutral300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  stock.amount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                Text(
                  stock.pieces,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: extendedColors.neutral300,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.profit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: profitColor,
                  ),
                ),
                Text(
                  '$arrow ${stock.changePercent}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: profitColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    _StockHistory item,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: extendedColors.neutral500),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  item.symbol,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.name.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    item.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: extendedColors.neutral500),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  l10n.totalProfit,
                  item.totalProfit,
                  theme,
                  extendedColors,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  l10n.realizedProfit,
                  item.realizedProfit,
                  theme,
                  extendedColors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  l10n.unrealizedProfit,
                  item.unrealizedProfit,
                  theme,
                  extendedColors,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  l10n.dividendProfit,
                  item.dividendProfit,
                  theme,
                  extendedColors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: extendedColors.neutral300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
      ],
    );
  }
}

class _StockHolding {
  final String symbol;
  final String name;
  final String amount;
  final String pieces;
  final String profit;
  final String changePercent;
  final bool isPositive;

  const _StockHolding({
    required this.symbol,
    required this.name,
    required this.amount,
    required this.pieces,
    required this.profit,
    required this.changePercent,
    required this.isPositive,
  });

  /// /stocks/mystocks мөрөөс угсарна:
  /// { SYMBOL, STOCKNAME, AMT, CLOSEPRICE, OPENPRICE, PRICECHANGE, ISFOREIGN }
  factory _StockHolding.fromApi(Map<String, dynamic> row) {
    final isForeign = row['ISFOREIGN']?.toString() == '1';
    final change = double.tryParse(row['PRICECHANGE']?.toString() ?? '');
    final close = double.tryParse(row['CLOSEPRICE']?.toString() ?? '');
    final open = double.tryParse(row['OPENPRICE']?.toString() ?? '');
    // Ханшийн өөрчлөлт (нэгж үнээр) — OPEN/CLOSE хоёулаа байвал
    final diff = (close != null && open != null) ? close - open : null;
    return _StockHolding(
      symbol: row['SYMBOL']?.toString() ?? '',
      name: (row['STOCKNAME'] ?? row['COMPNAME'])?.toString() ?? '',
      amount: formatStockAmount(row['AMT'], isForeign: isForeign),
      // Ширхэгийн мэдээлэл API-д алга — хаалтын ханшийг харуулна
      pieces: formatStockAmount(row['CLOSEPRICE'], isForeign: isForeign),
      profit: diff == null
          ? '-'
          : formatStockAmount(diff.abs(), isForeign: isForeign),
      changePercent: change == null ? '' : '${change.abs().toStringAsFixed(2)}%',
      isPositive: (change ?? diff ?? 0) >= 0,
    );
  }
}

class _StockHistory {
  final String symbol;
  final String name;
  final String totalProfit;
  final String realizedProfit;
  final String unrealizedProfit;
  final String dividendProfit;

  const _StockHistory({
    required this.symbol,
    required this.name,
    required this.totalProfit,
    required this.realizedProfit,
    required this.unrealizedProfit,
    required this.dividendProfit,
  });
}
