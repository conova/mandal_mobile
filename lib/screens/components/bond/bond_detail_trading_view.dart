import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mandal_capital/screens/components/bond/bond_trading_input_box.dart';
import 'package:mandal_capital/screens/components/bond/bond_trading_quantity_selector.dart';
import 'package:mandal_capital/screens/components/stock_trading/stock_trading_order_board.dart';
import 'package:mandal_capital/widgets/currency_suffix_formatter.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../../../common/bond_accrued_interest.dart';
import '../../../common/stock_row_format.dart';
import '../../../services/auth_service.dart';
import '../../../services/holiday_service.dart';
import '../../../services/time_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../models/order_book_entry.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/custom_svg_icon.dart';
import '../../../widgets/release_locked_amount_sheet.dart';
import 'bond_payment_details.dart';
import 'bond_payment_details_bottom_sheet.dart';
import 'bond_payment_schedule.dart';

/// Хоёрдогч + НЭЭЛТТЭЙ бондын арилжааны дизайн: авах ханш, ширхэг
/// сонгогч, төлбөрийн задаргаа, захиалгын самбар.
class BondDetailTradingView extends StatefulWidget {
  final double cash;
  final MarketInstrument bond;
  final double price;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onPriceChanged;

  const BondDetailTradingView({
    super.key,
    required this.cash,
    required this.bond,
    required this.price,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onPriceChanged,
  });

  @override
  State<BondDetailTradingView> createState() => _BondDetailTradingViewState();
}

class _BondDetailTradingViewState extends State<BondDetailTradingView> {
  /// Шимтгэлийн хувь (1 = 1%) — /user/fees-аас STOCKTYPE-аар нь татна
  double _feePct = 0;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late FocusNode _priceFocusNode;
  late FocusNode _quantityFocusNode;

  List<OrderBookEntry> _buyOrders = const [];
  List<OrderBookEntry> _sellOrders = const [];
  bool _orderBookLoading = true;
  Timer? _orderBookTimer;
  bool _orderBookFetching = false;

  @override
  void initState() {
    super.initState();
    // Хуримтлагдсан хүүгийн захиалгын өдрийг UB бодит цагаар тооцно
    // Ажлын өдрөөс нийтийн амралтын өдрүүдийг хасна
    Future.wait([TimeService.sync(), HolidayService.load()]).then((_) {
      if (mounted) setState(() {});
    });
    final initialPrice = widget.bond.closePrice ?? widget.bond.openPrice ?? 0;
    _priceController = TextEditingController(
      text: CurrencySuffixFormatter.format(initialPrice.toString(), suffix: '₮'),
    );
    _quantityController = TextEditingController(
      text: CurrencySuffixFormatter.format(widget.quantity.toString(), suffix: ''),
    );
    _priceFocusNode = FocusNode();
    _quantityFocusNode = FocusNode();

    _priceController.addListener(_onInputsChanged);
    _quantityController.addListener(_onInputsChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFee();
      _fetchOrderBook();
      _startOrderBookPolling();
    });
  }

  void _startOrderBookPolling() {
    _orderBookTimer?.cancel();
    _orderBookTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchOrderBook(),
    );
  }

  Future<void> _fetchFee() async {
    if (!mounted) return;
    final raw = widget.bond.raw;
    final isPrimary = raw['MARKET']?.toString().toLowerCase() == 'primary';
    final pct = await context.read<AuthService>().getFeePercent(
          stockType: raw['STOCKTYPE']?.toString() ?? '',
          ipo: isPrimary,
        );
    if (mounted) setState(() => _feePct = pct);
  }

  Future<void> _fetchOrderBook() async {
    final stockcode = widget.bond.stockcode;
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

  @override
  void didUpdateWidget(BondDetailTradingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Sync quantity if it changes from outside
    if (oldWidget.quantity != widget.quantity) {
      final formatted = CurrencySuffixFormatter.format(widget.quantity.toString(), suffix: '');
      if (_quantityController.text != formatted) {
        _quantityController.text = formatted;
      }
    }

    if (oldWidget.bond.stockcode != widget.bond.stockcode) {
      _fetchOrderBook();
      _startOrderBookPolling();
    }
  }

  @override
  void dispose() {
    _orderBookTimer?.cancel();
    _priceController.removeListener(_onInputsChanged);
    _quantityController.removeListener(_onInputsChanged);
    _priceController.dispose();
    _quantityController.dispose();
    _priceFocusNode.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _onInputsChanged() {
    setState(() {});
    widget.onPriceChanged.call(_currentPrice.toDouble());
    widget.onQuantityChanged.call(_currentQuantity);
  }

  /// Үнэ — "100,000.0₮" хэлбэрийн текстээс; аравтын цэгийг хадгална
  /// (цэгийг хасвал 100000.0 → 1000000 болж 10 дахин өсдөг)
  double get _currentPrice {
    final text = _priceController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(text) ?? 0;
  }

  int get _currentQuantity {
    final text = _quantityController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final commissionRate = _feePct / 100;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final price = _currentPrice;
    final quantity = _currentQuantity;
    //final total = (price * quantity).toDouble() + (price * quantity).toDouble() * commissionRate;
    final accruedInterest = openBondAccruedInterest(widget.bond);

    // Авах: (үнэ + ХХ) × тоо + шимтгэл; шимтгэл ХХ дээр ч тооцогдоно
    final unitPrice = price + accruedInterest;
    final commission = quantity * unitPrice * commissionRate;
    final totalPayment = (quantity * unitPrice) + commission;
    final yieldInfo = openBondYield(
      widget.bond,
      unitCost: unitPrice * (1 + commissionRate),
    );

    //final expectedReturn = total * rate / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.bond.name} ',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    if (widget.bond.subtitle.isNotEmpty)
                      TextSpan(
                        text: widget.bond.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.neutral200,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${l10n.availableCash}: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                  Text(
                    formatStockAmount(widget.cash, decimals: 0),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.primaryMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Авах ханш
              BondTradingInputBox(
                label: l10n.buyRate,
                controller: _priceController,
                focusNode: _priceFocusNode,
                currencySymbol: '₮',
              ),
              BondTradingQuantitySelector(
                controller: _quantityController,
                focusNode: _quantityFocusNode,
                onIncrease: () {
                  final current = _currentQuantity;
                  final newVal = current + 1;
                  _quantityController.text = CurrencySuffixFormatter.format(newVal.toString(), suffix: '');
                },
                onDecrease: () {
                  final current = _currentQuantity;
                  if (current > 0) {
                    final newVal = current - 1;
                    _quantityController.text = CurrencySuffixFormatter.format(newVal.toString(), suffix: '');
                  }
                },
                onChanged: (val) {},
              ),
              const SizedBox(height: 24),
              BondPaymentDetails(
                totalPayment: formatStockAmount(totalPayment, decimals: 2),
                // Өгөөж — биелэх өдрөөс хойш авах хүүгийн нийлбэр × тоо,
                // хажууд нь YTM rate (шимтгэлтэй нэг ширхэгийн төлөх дүнгээр)
                yieldValue: formatStockAmount(
                  yieldInfo.perUnit * quantity,
                  decimals: 0,
                ),
                yieldRate: yieldInfo.ytm == null
                    ? null
                    : '${yieldInfo.ytm!.toStringAsFixed(2)}%',
                onDetailsPressed: () {
                  showBondPaymentDetailsSheet(
                    context: context,
                    quantity: quantity,
                    piecePrice: _currentPrice.toDouble(),
                    accruedInterest: accruedInterest,
                    commissionRate: commissionRate,
                    feeIncludesAccruedInterest: true,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Divider(height: 1, color: extendedColors.neutral500),
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
            marketPrice: widget.bond.stockPrice ?? widget.bond.closePrice ?? 0,
          ),
      ],
    );
  }
}

/// Нээлттэй бондын нэг ширхэгийн хуримтлагдсан хүү — захиалга биелэх өдөр
/// (захиалгын арилжааны өдрөөс хойш ажлын SETTLEDAY хоног, анхдагч 2) хүртэл, Actual/365, татвар = STOCKFEE.
/// Нэрлэсэн үнэ = STOCKPRICE (хэрэглэгчийн оруулсан үнэ биш). USD бол 30/360.
double openBondAccruedInterest(MarketInstrument bond) {
  final startDt = parseStockDate(bond.startDate);
  final schedule = _scheduleOf(bond);
  return bondAccruedInterest(
    type: bond.isForeign ? BondAccrualType.usd : BondAccrualType.open,
    nominal: bond.stockPrice ?? 0,
    intRate: bond.intRate ?? 0,
    taxPct: bond.stockFee ?? 0,
    lastPaid: schedule?.lastPaid ?? startDt,
    // Захиалгын өдөр — UB бодит цаг, ETRADE-ээс хойш / амралтын өдөр бол
    // дараагийн ажлын өдөр; биелэх өдөр нь түүнээс хойш ажлын 2 хоног
    orderDate: bondOrderTradeDate(TimeService.nowUb(), eTrade: bond.eTrade),
    // Биелэх ажлын хоног — SETTLEDAY, ирээгүй бол 2
    settleDays: _settleDaysOf(bond),
  );
}

BondSchedule? _scheduleOf(MarketInstrument bond) => BondSchedule.build(
      start: parseStockDate(bond.startDate),
      end: parseStockDate(bond.endDate),
      payPeriod: bond.payType,
    );

int _settleDaysOf(MarketInstrument bond) =>
    int.tryParse(bond.settleDay.trim()) ?? 2;

/// Нээлттэй бондын өгөөж — захиалга биелэх өдрөөс (худалдан авагч бондыг
/// эзэмшиж эхлэх өдөр) хойш авах купоны нийлбэр (нэг ширхэг) болон YTM rate.
/// [unitCost] — нэг ширхэгийн нийт төлөх дүн (үнэ + ХХ + шимтгэл).
({double perUnit, double? ytm}) openBondYield(
  MarketInstrument bond, {
  required double unitCost,
}) {
  final schedule = _scheduleOf(bond);
  if (schedule == null) return (perUnit: 0, ytm: null);
  final settle = addBusinessDays(
    bondOrderTradeDate(TimeService.nowUb(), eTrade: bond.eTrade),
    _settleDaysOf(bond),
  );
  final nominal = bond.stockPrice ?? 0;
  final flows = bondFutureCouponFlows(
    dueDates: schedule.dueDates,
    start: schedule.start,
    nominal: nominal,
    intRate: bond.intRate ?? 0,
    taxPct: bond.stockFee ?? 0,
    isUsd: bond.isForeign,
    from: settle,
  );
  return (
    perUnit: flows.fold(0.0, (sum, f) => sum + f.amount),
    ytm: bondYtm(
      price: unitCost,
      coupons: flows,
      nominal: nominal,
      maturity: schedule.end,
      from: settle,
    ),
  );
}

/// Арилжааны дизайны доод хэсэг: түгжигдсэн дүнгийн banner + захиалга
/// өгөх товч (ширхэг 0 үед идэвхгүй).
class BondDetailTradingBottomBar extends StatelessWidget {
  final MarketInstrument? bond;
  final double price;
  final int quantity;
  final double? lockedAmount;

  const BondDetailTradingBottomBar({
    super.key,
    required this.bond,
    required this.price,
    required this.quantity,
    this.lockedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        border: BorderDirectional(
          top: BorderSide(color: extendedColors.neutral500, width: 1),
        )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lockedAmount != null && lockedAmount! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: extendedColors.primary200),
              child: Row(
                children: [
                  CustomSvgIcon('info-circle', color: extendedColors.primaryMain, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.lockedAmountLabel}: ${formatStockAmount(lockedAmount ?? 0, isForeign: bond?.isForeign ?? false)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await ReleaseLockedAmountSheet.show(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.release,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: extendedColors.primaryMain,
                          ),
                        ),
                        CustomSvgIcon('chevron-up', color: extendedColors.primaryMain, size: 16,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              bottom: true,
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.placeOrder,
                  onPressed: (quantity > 0 && price > 0)
                      ? () async {
                          final raw = bond?.raw ?? const {};
                          // Шимтгэлийн хувь — /user/fees (кэштэй тул хурдан)
                          final isPrimary = raw['MARKET']
                                  ?.toString()
                                  .toLowerCase() ==
                              'primary';
                          final feePct =
                              await context.read<AuthService>().getFeePercent(
                                    stockType:
                                        raw['STOCKTYPE']?.toString() ?? '',
                                    ipo: isPrimary,
                                  );
                          if (!context.mounted) return;
                          // (үнэ + ХХ) × тоо дээр шимтгэл — карт, sheet-тэй ижил
                          final accrued = bond == null
                              ? 0.0
                              : openBondAccruedInterest(bond!);
                          final gross = (price + accrued) * quantity;
                          final fee = gross * feePct / 100;
                          final exp = DateTime.now()
                              .add(const Duration(days: 30));
                          String two(int n) => n.toString().padLeft(2, '0');
                          final symbol = bond?.symbol ?? '';
                          Navigator.pushNamed(
                            context,
                            '/bond_confirmation',
                            arguments: {
                              'bond': raw,
                              'qty': quantity,
                              'price': price,
                              'fee': fee,
                              'feePct': feePct,
                              'accruedInterest': accrued * quantity,
                              'total': gross + fee,
                              'isForeign': bond?.isForeign ?? false,
                              'order': {
                                'STOCKCODE': bond?.stockcode ?? '',
                                'CNT': quantity.toString(),
                                'PRICE': price.toString(),
                                // 0 — авах
                                'TXNTYPE': '0',
                                'ORDERTYPE': '1',
                                'CONDID': '18',
                                'DESCR':
                                    'App: $symbol бонд авах $quantity ширхэг, нэгж үнэ $price',
                                'EXPDATE':
                                    '${exp.year}/${two(exp.month)}/${two(exp.day)}',
                                'FEE': '1',
                              },
                            },
                          );
                        }
                      : null,
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}
