import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../models/market_instrument.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';

class StockPortfolioScreen extends StatefulWidget {
  const StockPortfolioScreen({super.key});

  @override
  State<StockPortfolioScreen> createState() => _StockPortfolioScreenState();
}

class _StockPortfolioScreenState extends State<StockPortfolioScreen> {
  bool _isLoading = true;
  List<MarketInstrument> _holdings = const [];

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
        _holdings = MarketInstrument.listFromJson(rows);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
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
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/images/add_folder.png',
                      height: 101,
                      errorBuilder: (_, _, _) => const SizedBox(height: 80),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noStocksYet,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.startInvestingPrompt,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: FontWeight.w200
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 130,
                      child: CustomButton(
                        variant: CustomButtonVariant.orange,
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/home');
                        },
                        label: l10n.add,
                        size: CustomButtonSize.small,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [extendedColors.orange200, extendedColors.bgBase],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              // Back товч зүүн талд, icon мөрийн голд
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CircleBackButton(),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: extendedColors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CustomSvgIcon(
                        'coins-swap-02',
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.stocks,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 8),
            _buildAmountText('50,000,000.00₮', theme, extendedColors),
          ],
        ),
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
    MarketInstrument stock,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    // Ханшийн өөрчлөлт (нэгж үнээр) — OPEN/CLOSE хоёулаа байвал
    final diff = (stock.closePrice != null && stock.openPrice != null)
        ? stock.closePrice! - stock.openPrice!
        : null;
    final change = stock.priceChange;
    final isPositive = (change ?? diff ?? 0) >= 0;
    final profitColor = isPositive
        ? extendedColors.primaryMain
        : extendedColors.red;
    final arrow = isPositive ? 'button-up' : 'button-down';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
                  formatStockAmount(stock.amt, isForeign: stock.isForeign),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                Text(
                  formatStockAmount(
                    stock.closePrice,
                    isForeign: stock.isForeign,
                  ),
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
                  diff == null
                      ? '-'
                      : formatStockAmount(
                          diff.abs(),
                          isForeign: stock.isForeign,
                        ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: profitColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (change != null)
                      CustomSvgIcon(
                        arrow,
                        size: 6,
                        color: profitColor,
                      ),
                    const SizedBox(width: 4,),
                    Text(
                      change == null
                          ? '-'
                          : '${change.abs().toStringAsFixed(2)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: profitColor,
                      ),
                    ),
                  ],
                )
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
