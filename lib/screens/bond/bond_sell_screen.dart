import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mandal_capital/screens/components/stock_trading/stock_trading_order_board.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../models/order_book_entry.dart';
import '../../services/auth_service.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_svg_icon.dart';
import '../../widgets/currency_suffix_formatter.dart';
import '../components/bond/bond_payment_details_bottom_sheet.dart';
import '../components/bond/bond_trading_input_box.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_price_slider.dart';
import '../components/bond/bond_order_board.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_button.dart';

class BondSellScreen extends StatefulWidget {
  const BondSellScreen({super.key});

  @override
  State<BondSellScreen> createState() => _BondSellScreenState();
}

class _BondSellScreenState extends State<BondSellScreen> {
  int _quantity = 1;
  Map<String, dynamic> _bond = const {};
  bool _argsParsed = false;
  double _selectedPrice = 0;

  /// Шимтгэлийн хувь (1 = 1%) — /user/fees-аас STOCKTYPE-аар нь татна
  double _feePct = 0;

  List<OrderBookEntry> _sellOrders = const [];
  List<OrderBookEntry> _buyOrders = const [];
  bool _orderBookLoading = true;
  Timer? _orderBookTimer;
  bool _orderBookFetching = false;

  late TextEditingController _priceController;
  late FocusNode _priceFocusNode;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _priceFocusNode = FocusNode();
    _priceController.addListener(_onPriceInputChanged);
  }

  @override
  void dispose() {
    _orderBookTimer?.cancel();
    _priceController.removeListener(_onPriceInputChanged);
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  void _onPriceInputChanged() {
    final text = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final price = double.tryParse(text) ?? 0;
    if (_selectedPrice != price) {
      setState(() => _selectedPrice = price);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) _bond = Map<String, dynamic>.from(args);
    _selectedPrice = _unitPrice;

    _priceController.text = CurrencySuffixFormatter.format(
      _selectedPrice.toInt().toString(),
      suffix: '₮',
    );

    _fetchFee();
    _fetchOrderBook();

    final stockcode = _str(['STOCKCODE']);
    if (stockcode.isNotEmpty) {
      _orderBookTimer?.cancel();
      _orderBookTimer = Timer.periodic(
        const Duration(seconds: 5),
            (_) => _fetchOrderBook(),
      );
    }
  }

  Future<void> _fetchFee() async {
    final isPrimary = _bond['MARKET']?.toString().toLowerCase() == 'primary';
    final pct = await context.read<AuthService>().getFeePercent(
      stockType: _bond['STOCKTYPE']?.toString() ?? '',
      ipo: isPrimary,
    );
    if (mounted) setState(() => _feePct = pct);
  }

  Future<void> _fetchOrderBook() async {
    final stockcode = _str(['STOCKCODE']);
    if (stockcode.isEmpty) {
      if (mounted) setState(() => _orderBookLoading = false);
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

  double _num(List<String> keys) {
    for (final k in keys) {
      final v = num.tryParse(_bond[k]?.toString() ?? '');
      if (v != null && v > 0) return v.toDouble();
    }
    return 0;
  }

  String _str(List<String> keys) {
    for (final k in keys) {
      final v = _bond[k]?.toString() ?? '';
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  double get _unitPrice =>
      _num(['UNITPRICE', 'CLOSEPRICE', 'STOCKPRICE', 'PRICE']);

  double get _ownedAmount => _num(['AMT']);

  bool get _isForeign => _bond['ISFOREIGN']?.toString() == '1';

  bool get _isOpen => (_bond['ISOPEN']?.toString() ?? '1') == '1';

  /// Эзэмшиж буй ширхэг — CNT талбар ирвэл түүнийг, үгүй бол дүн/нэгж үнэ
  int get _maxQuantity {
    final cnt = _num(['CNT', 'CURRENTBAL']);
    if (cnt > 0) return cnt.floor();
    if (_unitPrice > 0) return (_ownedAmount / _unitPrice).floor();
    return 0;
  }

  double get _price => _selectedPrice > 0 ? _selectedPrice : _unitPrice;
  double get _total => _quantity * _price;
  double get _fee => _total * _feePct / 100;

  /// Хүлээн авах дүн — нийт дүнгээс шимтгэл хассан
  double get _proceeds => _total - _fee;

  void _placeOrder() {
    final l10n = AppLocalizations.of(context)!;
    final exp = DateTime.now().add(const Duration(days: 30));
    String two(int n) => n.toString().padLeft(2, '0');
    final symbol = _str(['SYMBOL']);

    Navigator.pushNamed(
      context,
      '/bond_sell_confirmation',
      arguments: {
        'bond': _bond,
        'qty': _quantity,
        'price': _price,
        'fee': _fee,
        'feePct': _feePct,
        'total': _proceeds,
        'isForeign': _isForeign,
        'totalLabel': l10n.receivableAmountLabel,
        'order': {
          'STOCKCODE': _str(['STOCKCODE']),
          'CNT': _quantity.toString(),
          'PRICE': _price.toString(),
          // 1 — зарах
          'TXNTYPE': '1',
          'ORDERTYPE': '1',
          'CONDID': '18',
          'DESCR': 'App: $symbol бонд зарах $_quantity ширхэг, '
              'нэгж үнэ $_price',
          'EXPDATE': '${exp.year}/${two(exp.month)}/${two(exp.day)}',
          'FEE': '1',
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircleBackButton(),
          ),
        ),
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    _str(['STOCKNAME', 'COMPNAME', 'SYMBOL']),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    _str(['COMPNAME2', 'TYPENAME']),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.ownedAmountLabel}: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                Text(
                  formatStockAmount(_ownedAmount, isForeign: _isForeign, decimals: 0),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.primaryMain,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Render view dynamically based on bond openness
            if (_isOpen) _buildOpenBondControls() else _buildClosedBondControls(),

            const SizedBox(height: 16),

            // Хүлээн авах дүн Card
            _buildProceedsCard(l10n, extendedColors, theme),
            const SizedBox(height: 16),

            if (!_isOpen) _buildInfoBanner(l10n, extendedColors, theme),
            const SizedBox(height: 24),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 20),

            if (_orderBookLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_isOpen)
              StockTradingOrderBoard(
                buyOrders: _buyOrders,
                sellOrders: _sellOrders,
                marketPrice: _unitPrice,
              )
            else
              BondOrderBoard(
                orders: _sellOrders
                    .map((e) => BondOrderEntry(
                  price: e.price.toInt(),
                  quantity: e.quantity,
                ))
                    .toList(),
              ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: extendedColors.bgBase,
          boxShadow: [
            BoxShadow(
              color: extendedColors.neutral500,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: l10n.placeOrder,
            onPressed: _quantity > 0 && _price > 0 ? _placeOrder : null,
          ),
        ),
      ),
    );
  }

  /// Open Bond Controls (Input Box for custom sell rate + Quantity Selector)
  Widget _buildOpenBondControls() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        BondTradingInputBox(
          label: l10n.sellingPrice,
          controller: _priceController,
          focusNode: _priceFocusNode,
          currencySymbol: '₮',
        ),
        BondQuantitySelector(
          maxQuantity: _maxQuantity,
          initialQuantity: _quantity,
          onChanged: (val) => setState(() => _quantity = val),
          isBuy: false,
          label: l10n.barePiece,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          )
        ),
      ],
    );
  }

  /// Closed Bond Controls (Price Range Slider + Connected Quantity Selector)
  Widget _buildClosedBondControls() {
    return Column(
      children: [
        if (_unitPrice > 0)
          BondPriceSlider(
            min: _unitPrice * 0.98,
            max: _unitPrice * 1.02,
            initialValue: _unitPrice,
            onChanged: (price) {
              setState(() {
                _selectedPrice = price;
                _priceController.text = CurrencySuffixFormatter.format(
                  price.toInt().toString(),
                  suffix: '₮',
                );
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        BondQuantitySelector(
          maxQuantity: _maxQuantity,
          initialQuantity: _quantity,
          onChanged: (val) => setState(() => _quantity = val),
          isBuy: false,
          borderRadius: (_unitPrice > 0)
              ? const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          )
              : null,
        ),
      ],
    );
  }

  Widget _buildProceedsCard(
      AppLocalizations l10n,
      ExtendedColors extendedColors,
      ThemeData theme,
      ) {
    final double accruedInterest = _num(['ACCRUEDINTEREST', 'INTEREST']);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BondPaymentDetailsBottomSheet(
            quantity: _quantity,
            piecePrice: _price,
            accruedInterest: accruedInterest,
            commissionRate: _feePct / 100,
            isSell: true,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.recieveAmount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      formatStockAmount(_proceeds, isForeign: _isForeign, decimals: 0),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  CustomSvgIcon(
                    'chevron-right',
                    color: extendedColors.neutral200,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(
      AppLocalizations l10n,
      ExtendedColors extendedColors,
      ThemeData theme,
      ) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [extendedColors.primary500, extendedColors.primary300],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [extendedColors.primary200, extendedColors.primary100],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomSvgIcon(
                'annotation-info',
                size: 20,
                color: extendedColors.primaryMain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.sellPriceDesc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}