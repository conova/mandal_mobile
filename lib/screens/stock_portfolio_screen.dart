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

  /// Түүхийн хэсэгт дэлгэрүүлж харуулсан хувьцаанууд (symbol)
  final Set<String> _expandedSymbols = {};

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

  /// Home-ийн хөрөнгийн задаргаанаас дамжуулсан нийт дүн
  double? _headerAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _headerAmount = (args['amount'] as num?)?.toDouble() ?? _headerAmount;
    }

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
                style: theme.textTheme.headlineSmall?.copyWith(
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral200,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.amountPieces,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral200,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.profitPlusMinus,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral200,
                        fontWeight: FontWeight.w300,
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
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 130,
                      child: CustomButton(
                        variant: CustomButtonVariant.orange,
                        onPressed: () async {
                          await Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false, arguments: {'tab': 2});
                        },
                        label: l10n.buyStock,
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
            // Түүхэн ашиг/алдагдал — нийлбэр товчоо, дараа нь хувьцаа
            // тус бүрийн задаргаа (дэлгэрүүлж үзнэ)
            if (_holdings.isNotEmpty) ...[
              const SizedBox(height: 28),
              _buildHistorySummary(theme, extendedColors, l10n),
              const SizedBox(height: 24),
              ..._holdings.map(
                (stock) =>
                    _buildHistoryCard(stock, theme, extendedColors, l10n),
              ),
            ],
            // Хэрэгжээгүй ашгийн тайлбар — шимтгэл, татвар ороогүй
            if (_holdings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  l10n.unrealizedProfitNote,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: extendedColors.neutral300,
                  ),
                ),
              ),
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
            _buildAmountText(
              formatStockAmount(_headerAmount ?? 0),
              theme,
              extendedColors,
              false
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountText(
    String amount,
    ThemeData theme,
    ExtendedColors extendedColors,
    bool isMedium,
  ) {
    final dotIndex = amount.indexOf('.');
    if (dotIndex == -1) {
      return Text(
        amount,
        style: (isMedium? theme.textTheme.labelMedium : theme.textTheme.headlineLarge)?.copyWith(
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
            style: (isMedium? theme.textTheme.headlineMedium : theme.textTheme.headlineLarge)?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          TextSpan(
            text: decimalPart,
            style: (isMedium? theme.textTheme.headlineMedium : theme.textTheme.headlineLarge)?.copyWith(
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
    // Ашиг +/- — API-ийн PROFIT, хувь нь UNREALIZEDRATE
    final diff = stock.profit;
    final change = stock.unrealizedRate;
    final isPositive = (diff ?? change ?? 0) >= 0;
    final profitColor = isPositive
        ? extendedColors.primaryMain
        : extendedColors.red;
    final arrow = isPositive ? 'button-up' : 'button-down';

    // Мөр дээр дарахад stock detail дэлгэц рүү шилжинэ
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/stock_detail',
        arguments: {
          'symbol': stock.symbol,
          'name': stock.name,
          'price': formatStockAmount(
            stock.closePrice,
            isForeign: stock.curCode != 'MNT',
          ),
          'change': change == null
              ? '-'
              : '${change.abs().toStringAsFixed(2)}%',
          'isGrowing': isPositive,
          'stockcode': stock.stockcode,
        },
      ),
      child: Padding(
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  Text(
                    stock.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral200,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Ямар ч үед 1 мөрөнд багтана — багтахгүй бол жижгэрнэ
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatStockAmount(
                        (stock.currentBal ?? 0) * (stock.closePrice ?? 0),
                        isForeign: stock.curCode != 'MNT',
                      ),
                      maxLines: 1,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                  Text(
                    formatNumbers(stock.currentBal),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: extendedColors.neutral200,
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
                            isForeign: stock.curCode != 'MNT',
                          ),
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: profitColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (change != null)
                        CustomSvgIcon(arrow, size: 6 , color: profitColor),
                      const SizedBox(width: 4),
                      Text(
                        change == null
                            ? '-'
                            : '${change.abs().toStringAsFixed(2)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: profitColor,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Түүхэн ашиг/алдагдлын товчоо — icon, нийт дүн, хэрэгжсэн ашиг болон
  /// ногдол ашгийн багана
  Widget _buildHistorySummary(
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    double sumOf(double? Function(MarketInstrument s) pick) =>
        _holdings.fold(0.0, (sum, s) => sum + (pick(s) ?? 0));

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: extendedColors.bgBase,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: extendedColors.orange.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: CustomSvgIcon(
              'clock-refresh',
              color: extendedColors.orange,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.historicalProfitLoss,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral200,
            fontWeight: FontWeight.w200,
          ),
        ),
        const SizedBox(height: 8),
        _buildAmountText(
          formatStockAmount(sumOf((s) => s.totalProfit)),
          theme,
          extendedColors,
          true
        ),
        const SizedBox(height: 20),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildCenterStat(
                  l10n.realizedProfit,
                  formatStockAmount(sumOf((s) => s.realized)),
                  theme,
                  extendedColors,
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: extendedColors.neutral500,
              ),
              Expanded(
                child: _buildCenterStat(
                  l10n.dividendProfit,
                  formatStockAmount(sumOf((s) => s.dividend)),
                  theme,
                  extendedColors,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterStat(
    String label,
    String value,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: extendedColors.neutral200,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral100,
            ),
          ),
        ),
      ],
    );
  }

  /// Хувьцаа тус бүрийн задаргаа — дарахад дэлгэрч 4 үзүүлэлт харагдана
  Widget _buildHistoryCard(
    MarketInstrument stock,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final isExpanded = _expandedSymbols.contains(stock.symbol);
    final isForeign = stock.curCode != 'MNT';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedSymbols.remove(stock.symbol);
              } else {
                _expandedSymbols.add(stock.symbol);
              }
            }),
            child: Row(
              children: [
                Text(
                  stock.symbol,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stock.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: extendedColors.neutral200,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CustomSvgIcon(
                  isExpanded ? 'chevron-up' : 'chevron-down',
                  size: 20,
                  color: extendedColors.neutral200,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.totalProfit,
                    formatStockAmount(stock.totalProfit ?? 0,
                        isForeign: isForeign),
                    theme,
                    extendedColors,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n.realizedProfit,
                    formatStockAmount(stock.realized ?? 0,
                        isForeign: isForeign),
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
                    formatStockAmount(stock.unrealized ?? 0,
                        isForeign: isForeign),
                    theme,
                    extendedColors,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n.dividendProfit,
                    formatStockAmount(stock.dividend ?? 0,
                        isForeign: isForeign),
                    theme,
                    extendedColors,
                  ),
                ),
              ],
            ),
          ],
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
          style: theme.textTheme.labelLarge?.copyWith(
            color: extendedColors.neutral200,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral100,
          ),
        ),
      ],
    );
  }
}
