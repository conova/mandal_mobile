import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/order_book_entry.dart';
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

  Map<String, dynamic> _args = const {};
  bool _argsParsed = false;

  /// /stocks/order_book — авах/зарах талууд
  List<OrderBookEntry> _buyOrders = const [];
  List<OrderBookEntry> _sellOrders = const [];
  bool _orderBookLoading = true;

  /// Дэлгэц идэвхтэй байх үед самбарыг 5 секунд тутам шинэчилнэ
  Timer? _orderBookTimer;
  bool _orderBookFetching = false;

  /// Арилжааны төрөл: 1 — нөхцөлт үнэ, 2 — зах зээлийн үнэ
  /// (захиалгын ORDERTYPE талбараар илгээгдэнэ)
  int _orderType = 1;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '0.00₮');
    _quantityController = TextEditingController(text: '1');
    _priceFocusNode = FocusNode();
    _quantityFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    _args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        const {};
    _fetchOrderBook();

    // 5 секунд тутамд чимээгүй шинэчилнэ (dispose дээр зогсоно)
    if ((_args['stockcode']?.toString() ?? '').isNotEmpty) {
      _orderBookTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _fetchOrderBook(),
      );
    }
  }

  Future<void> _fetchOrderBook() async {
    final stockcode = _args['stockcode']?.toString() ?? '';
    if (stockcode.isEmpty) {
      setState(() => _orderBookLoading = false);
      return;
    }
    // Өмнөх хүсэлт дуусаагүй бол давхарлахгүй (удаан сүлжээнд хуримтлагдахгүй)
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
      // Зөвхөн анхны ачаалалтын алдааг мэдэгдэнэ —
      // 5 секундын давтан шинэчлэлтийнхийг чимээгүй өнгөрөөнө
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
    _priceController.dispose();
    _quantityController.dispose();
    _priceFocusNode.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  /// Арилжааны төрөл сонгох sheet — нөхцөлт үнэ (1) / зах зээлийн үнэ (2)
  Future<void> _showOrderTypeSheet() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    Widget option({
      required int type,
      required IconData icon,
      required String title,
      required String desc,
    }) {
      final isSelected = _orderType == type;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
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
                child: Icon(icon, size: 24, color: extendedColors.neutral100),
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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, _) => Container(
          decoration: BoxDecoration(
            color: extendedColors.bgBase,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
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
                  icon: Icons.north_east,
                  title: l10n.limitPrice,
                  desc: l10n.limitPriceDesc,
                ),
                Divider(height: 1, color: extendedColors.neutral500),
                option(
                  type: 2,
                  icon: Icons.bolt_outlined,
                  title: l10n.marketPrice,
                  desc: l10n.marketPriceDesc,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmation() {
    final symbol = _args['symbol']?.toString() ?? '';
    final price = double.tryParse(
          _priceController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0;
    final cnt = int.tryParse(
          _quantityController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    // Дуусах хугацаа — 30 хоног (yyyy/MM/dd)
    final exp = DateTime.now().add(const Duration(days: 30));
    String two(int n) => n.toString().padLeft(2, '0');
    final expDate = '${exp.year}/${two(exp.month)}/${two(exp.day)}';

    Navigator.pushNamed(
      context,
      '/stock_confirmation',
      arguments: {
        'symbol': symbol,
        'order': {
          'STOCKCODE': _args['stockcode']?.toString() ?? '',
          'CNT': cnt.toString(),
          'PRICE': price.toString(),
          // 0 — авах, 1 — зарах
          'TXNTYPE': '0',
          'ORDERTYPE': _orderType.toString(),
          'CONDID': '18',
          // Тайлбарыг автоматаар үүсгэнэ
          'DESCR': 'App: $symbol авах $cnt ширхэг, нэгж үнэ $price',
          'EXPDATE': expDate,
          'FEE': '1',
        },
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
                // mainAxisSize.min + Flexible-гүй — AppBar actions хязгааргүй
                // өргөн өгдөг тул Flexible ашиглавал layout crash болж
                // бүх AppBar (back товч) ажиллахгүй болдог
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
                        '${_args['symbol']} - ${l10n.buyTab}',
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
                              text: '142,000.53₮',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: extendedColors.primaryMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1 MNDL = 65.62₮',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                          setState(() {
                            _quantity++;
                            _quantityController.text = _quantity.toString();
                          });
                        },
                        onDecrease: () {
                          setState(() {
                            if (_quantity > 1) {
                              _quantity--;
                              _quantityController.text = _quantity.toString();
                            }
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _quantity = int.tryParse(value) ?? 1;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const StockTradingPercentageSelector(),
                      const SizedBox(height: 16),
                      StockTradingInfoBox(
                        label: l10n.totalPaymentLabel,
                        value: '72.62₮',
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
        onPlaceOrder: _showConfirmation,
        onReleaseLocked: () => ReleaseLockedAmountSheet.show(context),
        lockedAmount: '129,341.30₮',
      ),
    );
  }
}
