import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/order_book_entry.dart';
import '../models/market_instrument.dart';
import '../widgets/currency_suffix_formatter.dart';
import '../widgets/release_locked_amount_sheet.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';
import 'components/stock_trading/stock_trading_input_box.dart';
import 'components/stock_trading/stock_trading_quantity_selector.dart';
import 'components/stock_trading/stock_trading_percentage_selector.dart';
import 'components/stock_trading/stock_trading_info_box.dart';
import 'components/stock_trading/stock_trading_order_board.dart';
import 'components/stock_trading/stock_trading_bottom_bar.dart';

class StockTradingScreen extends StatefulWidget {
  const StockTradingScreen({super.key});

  @override
  State<StockTradingScreen> createState() => _StockTradingScreenState();
}

class _StockTradingScreenState extends State<StockTradingScreen> {
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late FocusNode _priceFocusNode;
  late FocusNode _quantityFocusNode;

  int _quantity = 1;
  double _availableCash = 0;
  double _lockedAmount = 0;

  Map<String, dynamic> _args = const {};
  bool _argsParsed = false;

  /// Хувьцааны дэлгэрэнгүй мэдээлэл (арилжааны цаг, settle day г.м.)
  MarketInstrument? _stockInfo;

  /// /stocks/order_book — авах/зарах талууд
  List<OrderBookEntry> _buyOrders = const [];
  List<OrderBookEntry> _sellOrders = const [];
  bool _orderBookLoading = true;
  bool _isPortfolioLoading = true;

  /// Дэлгэц идэвхтэй байх үед самбарыг 5 секунд тутам шинэчилнэ
  Timer? _orderBookTimer;
  bool _orderBookFetching = false;

  /// Арилжааны төрөл: 1 — нөхцөлт үнэ, 2 — зах зээлийн үнэ
  /// (захиалгын ORDERTYPE талбараар илгээгдэнэ)
  int _orderType = 1;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: CurrencySuffixFormatter.format('0', suffix: '₮'),
    );
    _quantityController = TextEditingController(
      text: CurrencySuffixFormatter.format('1', suffix: ''),
    );
    _priceFocusNode = FocusNode();
    _quantityFocusNode = FocusNode();

    // Listen to changes to update the total payment box and validate the order
    _priceController.addListener(_onInputChanged);
    _quantityController.addListener(_onInputChanged);

    _fetchPortfolioSummary();
  }

  void _onInputChanged() {
    if (!mounted) return;
    final newQty = int.tryParse(
          _quantityController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    if (newQty != _quantity) {
      _quantity = newQty;
    }
    setState(() {});
  }

  double get _totalPayment {
    final priceStr = _priceController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final price = double.tryParse(priceStr) ?? 0;
    final qtyStr = _quantityController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final qty = int.tryParse(qtyStr) ?? 0;
    return price * qty;
  }

  bool get _isOrderValid {
    final priceStr = _priceController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final price = double.tryParse(priceStr) ?? 0;
    final qtyStr = _quantityController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final qty = int.tryParse(qtyStr) ?? 0;

    return price > 0 && qty > 0 && (price * qty) <= _availableCash;
  }

  void _handlePercentageSelected(String percentage) {
    final percent = double.tryParse(percentage.replaceAll('%', '')) ?? 0;
    final priceStr = _priceController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final price = double.tryParse(priceStr) ?? 0;

    if (price <= 0) return;

    final targetAmount = _availableCash * (percent / 100);
    final calculatedQty = (targetAmount / price).floor();

    if (calculatedQty > 0) {
      _quantityController.text = CurrencySuffixFormatter.format(
        calculatedQty.toString(),
        suffix: '',
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    _args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        const {};

    // Stock detail-с дамжуулсан info-г уншина
    if (_args['info'] != null) {
      _stockInfo = MarketInstrument.fromJson(_args['info']);
    }

    // Initial price pre-fill from arguments
    if (_args['price'] != null) {
      _priceController.text = CurrencySuffixFormatter.format(
        _args['price'].toString(),
        suffix: '₮',
      );
    }

    _fetchOrderBook();

    // 5 секунд тутамд чимээгүй шинэчилнэ (dispose дээр зогсоно)
    if ((_args['stockcode']?.toString() ?? '').isNotEmpty) {
      _orderBookTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _fetchOrderBook(),
      );
    }
  }

  Future<void> _fetchPortfolioSummary() async {
    try {
      final auth = context.read<AuthService>();
      final summary = await auth.getPortfolioSummary();
      if (!mounted) return;
      setState(() {
        _availableCash = summary.cashBalance - summary.holdAmount;
        _lockedAmount = summary.holdAmount;
        _isPortfolioLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching portfolio summary: $e');
      if (mounted) setState(() => _isPortfolioLoading = false);
    }
  }

  Future<void> _fetchOrderBook() async {
    final stockcode = _args['stockcode']?.toString() ?? '';
    if (stockcode.isEmpty) {
      setState(() => _orderBookLoading = false);
      return;
    }
    if (_orderBookFetching) return;
    _orderBookFetching = true;
    try {
      final rows = await context.read<AuthService>().getOrderBook(stockcode);
      if (!mounted) return;
      setState(() {
        _buyOrders = OrderBookEntry.sideFromJson(rows, 'BUY');
        _sellOrders = OrderBookEntry.sideFromJson(rows, 'SELL');
        _orderBookLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final wasInitialLoad = _orderBookLoading;
      setState(() => _orderBookLoading = false);
      if (wasInitialLoad) CustomSnackbar.showError(context, e);
    } finally {
      _orderBookFetching = false;
    }
  }

  @override
  void dispose() {
    _orderBookTimer?.cancel();
    _priceController.removeListener(_onInputChanged);
    _quantityController.removeListener(_onInputChanged);
    _priceController.dispose();
    _quantityController.dispose();
    _priceFocusNode.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  Future<void> _showOrderTypeSheet() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    // stock_detail-с дамжиж ирсэн арилжааны цаг болон статус
    final startTime = _stockInfo?.sTrade ?? '10:00';
    final endTime = _stockInfo?.eTrade ?? '13:00';
    final bool isMarketOpen = _stockInfo?.marketOpen ?? false;
    
    // Зах зээл хаалттай үед Market Order-ийг (type 2) хязгаарлана
    final bool isMarketRestricted = !isMarketOpen;

    bool warnUser = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {

          if (warnUser) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: extendedColors.bgBase,
                  boxShadow: [
                    BoxShadow(
                      color: extendedColors.neutral400,
                      offset: const Offset(0, -4),
                      blurRadius: 40,
                    )
                  ]
              ),
              // Жижиг дэлгэц/keyboard үед агуулга багтахгүй бол scroll болно
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: extendedColors.neutral300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: CustomSvgIcon('info-circle', size: 20, color: extendedColors.primaryMain,),
                    ),
                    const SizedBox(height: 24,),
                    Text(
                      l10n.marketClosedNotifTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.marketClosedNotifDesc(startTime, endTime),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: extendedColors.neutral100,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    CustomButton(
                      label: l10n.understood,
                      onPressed: () {
                        setSheetState(() => warnUser = false);
                        Navigator.pop(context);
                      },
                      variant: CustomButtonVariant.tertiary,
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            );
          }

          Widget option({
            required int type,
            required String icon,
            required String title,
            required String desc,
          }) {
            final isSelected = _orderType == type;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (type == 2 && isMarketRestricted) {
                  setSheetState(() => warnUser = true);
                  return;
                }
                setState(() => _orderType = type);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomSvgIcon(icon, size: 24, color: extendedColors.neutral100),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: extendedColors.neutral100,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: extendedColors.neutral200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check, color: extendedColors.primaryMain, size: 24),
                    ],
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: extendedColors.bgBase,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 16),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: extendedColors.neutral400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.tradeTypeTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  option(
                    type: 1,
                    icon: 'Union',
                    title: l10n.limitPrice,
                    desc: l10n.limitPriceDesc,
                  ),
                  Divider(height: 1, color: extendedColors.neutral500),
                  option(
                    type: 2,
                    icon: 'lightning-02',
                    title: l10n.marketPrice,
                    desc: l10n.marketPriceDesc,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showConfirmation() async {
    final symbol = _args['symbol']?.toString() ?? '';
    final name = _args['name']?.toString() ?? '';
    final priceStr = _priceController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    var price = double.tryParse(priceStr) ?? 0;
    final isSell = _args['side'] == 'sell';

    // Зах зээлийн үнэ (market order):
    //   авах — хамгийн хямд зарах ханш + 15%, зарах — хамгийн өндөр авах ханш
    if (_orderType == 2) {
      if (!isSell && _sellOrders.isNotEmpty) {
        final bestAsk = _sellOrders
            .map((o) => o.price)
            .reduce((a, b) => a < b ? a : b);
        if (bestAsk > 0) price = bestAsk * 1.15;
      } else if (isSell && _buyOrders.isNotEmpty) {
        final bestBid = _buyOrders
            .map((o) => o.price)
            .reduce((a, b) => a > b ? a : b);
        if (bestBid > 0) price = bestBid;
      }
    }
    
    // Extracting the 4 variables from passed data via _stockInfo
    final startTime = _stockInfo?.sTrade ?? '10:00';
    final endTime = _stockInfo?.eTrade ?? '13:00';
    final settleDay = _stockInfo?.settleDay ?? '2';
    final isMarketOpen = _stockInfo?.marketOpen ?? false;

    final qtyStr = _quantityController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cnt = int.tryParse(qtyStr) ?? 0;

    // Шимтгэлийн хувь — /user/fees (хувьцаа = STOCKTYPE 1)
    final feePct = await context
        .read<AuthService>()
        .getFeePercent(stockType: '1');
    if (!mounted) return;
    final fee = price * cnt * feePct / 100;

    final exp = DateTime.now().add(const Duration(days: 30));
    String two(int n) => n.toString().padLeft(2, '0');
    final expDate = '${exp.year}/${two(exp.month)}/${two(exp.day)}';

    Navigator.pushNamed(
      context,
      '/stock_confirmation',
      arguments: {
        'symbol': symbol,
        'name': name,
        // Шимтгэл, нийт дүн — /user/fees-ийн хувиар тооцсон
        'fee': fee,
        'feePct': feePct,
        'total': price * cnt + fee,
        'order': {
          'STOCKCODE': _args['stockcode']?.toString() ?? '',
          'CNT': cnt.toString(),
          'PRICE': price.toString(),
          // 0 — авах, 1 — зарах
          'TXNTYPE': isSell ? '1' : '0',
          'ORDERTYPE': _orderType.toString(),
          'CONDID': '18',
          'DESCR':
              'App: $symbol ${isSell ? 'зарах' : 'авах'} $cnt ширхэг, нэгж үнэ $price',
          'EXPDATE': expDate,
          'FEE': '1',
        },
        // Optionally pass these along if the confirmation screen needs them
        'settleDay': settleDay,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final isSell = _args['side'] == 'sell';
    final showWarningScreen = (!isSell && !_isPortfolioLoading && _availableCash == 0 && _lockedAmount == 0);


    if (showWarningScreen) {
      return Scaffold(
        backgroundColor: extendedColors.bgBase,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                          'assets/images/bookmark.png'
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Text(
                      l10n.stockTradingNoPowerTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      l10n.stockTradingNoPowerDesc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              CustomButton(
                label: l10n.makeIncome,
                variant: CustomButtonVariant.primary,
                onPressed: () => Navigator.pushNamed(context, '/income_method'),
              ),
              const SizedBox(height: 10,),
              CustomButton(
                label: l10n.back,
                variant: CustomButtonVariant.secondary,
                onPressed: Navigator.of(context).pop,
              ),
            ],
          ),
        )
      );
    }

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10),
            child: GestureDetector(
              onTap: _showOrderTypeSheet,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSvgIcon(
                      'chevron-down',
                      size: 20,
                      color: extendedColors.neutral100,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _orderType == 1 ? l10n.limitPrice : l10n.marketPrice,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: extendedColors.neutral100,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_args['symbol'] ?? ''} - ${isSell ? l10n.sellTab : l10n.buyTab}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: '${l10n.availableCash}: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral100,
                          ),
                          children: [
                            TextSpan(
                              text: CurrencySuffixFormatter.format(
                                  _availableCash.toString(),
                                  suffix: '₮'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: extendedColors.primaryMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1 ${_args['symbol'] ?? ''} = ${_args['price'] ?? '-'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_orderType == 2)
                        StockTradingInputBox(
                          label: l10n.marketPrice,
                          controller: _priceController,
                          focusNode: _priceFocusNode,
                          readOnly: true,
                          suffixText: '',
                        ),
                      if (_orderType == 1)
                        StockTradingInputBox(
                          label: l10n.limitPrice,
                          controller: _priceController,
                          focusNode: _priceFocusNode,
                          suffixText: l10n.paste,
                        ),
                      StockTradingQuantitySelector(
                        controller: _quantityController,
                        focusNode: _quantityFocusNode,
                        onIncrease: () {
                          _quantityController.text =
                              CurrencySuffixFormatter.format(
                                  (_quantity + 1).toString(),
                                  suffix: '');
                        },
                        onDecrease: () {
                          if (_quantity > 1) {
                            _quantityController.text =
                                CurrencySuffixFormatter.format(
                                    (_quantity - 1).toString(),
                                    suffix: '');
                          }
                        },
                        onChanged: (value) {
                          // Handled by controller listener
                        },
                      ),
                      const SizedBox(height: 16),
                      StockTradingPercentageSelector(
                        onPercentageSelected: _handlePercentageSelected,
                      ),
                      const SizedBox(height: 16),
                      StockTradingInfoBox(
                        label: isSell ? l10n.totalReceivableLabel : l10n.totalPaymentLabel,
                        value: CurrencySuffixFormatter.format(
                          _totalPayment.toString(),
                          suffix: '₮',
                        ),
                        valueColor: !isSell && _totalPayment > _availableCash
                            ? extendedColors.red
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderBoardTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_orderBookLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        StockTradingOrderBoard(
                          buyOrders: _buyOrders,
                          sellOrders: _sellOrders,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: StockTradingBottomBar(
        onPlaceOrder: _isOrderValid ? _showConfirmation : null,
        onReleaseLocked: () async {
          await ReleaseLockedAmountSheet.show(context);
          // Sheet дотор захиалга цуцалсан байж болзошгүй — түгжигдсэн дүн,
          // бэлэн мөнгөө дахин татна
          _fetchPortfolioSummary();
        },
        lockedAmount: CurrencySuffixFormatter.format(_lockedAmount.toString(),
            suffix: '₮'),
      ),
    );
  }
}
