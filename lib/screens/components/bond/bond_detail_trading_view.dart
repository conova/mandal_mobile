import 'package:flutter/material.dart';
import 'package:mandal_capital/screens/components/bond/bond_trading_input_box.dart';
import 'package:mandal_capital/screens/components/bond/bond_trading_quantity_selector.dart';
import 'package:mandal_capital/widgets/currency_suffix_formatter.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../../../common/stock_row_format.dart';
import '../../../services/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../models/order_book_entry.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';
import '../../../widgets/release_locked_amount_sheet.dart';
import 'bond_payment_details.dart';
import 'bond_payment_details_bottom_sheet.dart';
import 'bond_trading_order_board.dart';

/// Хоёрдогч + НЭЭЛТТЭЙ бондын арилжааны дизайн: авах ханш, ширхэг
/// сонгогч, төлбөрийн задаргаа, захиалгын самбар.
class BondDetailTradingView extends StatefulWidget {
  final MarketInstrument? bond;
  final double price;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onPriceChanged;

  const BondDetailTradingView({
    super.key,
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

  @override
  void initState() {
    super.initState();
    final initialPrice = widget.bond?.closePrice ?? widget.bond?.openPrice ?? 0;
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

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFee());
  }

  Future<void> _fetchFee() async {
    if (!mounted) return;
    final raw = widget.bond?.raw ?? const {};
    final isPrimary = raw['MARKET']?.toString().toLowerCase() == 'primary';
    final pct = await context.read<AuthService>().getFeePercent(
          stockType: raw['STOCKTYPE']?.toString() ?? '',
          ipo: isPrimary,
        );
    if (mounted) setState(() => _feePct = pct);
  }

  @override
  void didUpdateWidget(BondDetailTradingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the bond data arrives late (initially null), update the price controller
    if (oldWidget.bond == null && widget.bond != null) {
      _fetchFee();
      final newPrice = widget.bond?.closePrice ?? widget.bond?.openPrice ?? 0;
      final formatted = CurrencySuffixFormatter.format(newPrice.toString(), suffix: '₮');
      if (_priceController.text != formatted) {
        _priceController.text = formatted;
      }
    }
    
    // Sync quantity if it changes from outside
    if (oldWidget.quantity != widget.quantity) {
      final formatted = CurrencySuffixFormatter.format(widget.quantity.toString(), suffix: '');
      if (_quantityController.text != formatted) {
        _quantityController.text = formatted;
      }
    }
  }

  @override
  void dispose() {
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
    widget.onPriceChanged(_currentPrice.toDouble());
    widget.onQuantityChanged(_currentQuantity);
  }

  int get _currentPrice {
    final text = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(text) ?? 0;
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
    final total = (price * quantity).toDouble() + (price * quantity).toDouble() * commissionRate;
    final rate = widget.bond?.intRate ?? 0;
    final expectedReturn = total * rate / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            // widget.onQuantityChanged(newVal); // redundant due to listener
          },
          onDecrease: () {
            final current = _currentQuantity;
            if (current > 0) {
              final newVal = current - 1;
              _quantityController.text = CurrencySuffixFormatter.format(newVal.toString(), suffix: '');
              // widget.onQuantityChanged(newVal); // redundant due to listener
            }
          },
          onChanged: (val) {
            // redundant due to listener
          },
        ),
        const SizedBox(height: 24),
        BondPaymentDetails(
          totalPayment: formatStockAmount(total, decimals: 2),
          totalReturn: formatStockAmount(expectedReturn, decimals: 2),
          onDetailsPressed: () {
            //bond payment detail sheet
            // Хуримтлагдсан хүү - accruedInterest
            // Ширхэгийн үнэ - piecePrice
            showBondPaymentDetailsSheet(
              context: context,
              quantity: quantity,
              piecePrice: _currentPrice.toDouble(),
              accruedInterest: expectedReturn,
              commissionRate: commissionRate,
            );
          },
        ),
        const SizedBox(height: 32),
        Divider(height: 1, color: extendedColors.neutral500),
        const SizedBox(height: 24),
        // Захиалгын самбар — API байхгүй тул түр демо утгууд
        BondTradingOrderBoard(
          buyOrders: const [
            OrderBookEntry(price: 100000, quantity: 500, rank: 1),
            OrderBookEntry(price: 99500, quantity: 1200, rank: 2),
            OrderBookEntry(price: 99000, quantity: 800, rank: 3),
            OrderBookEntry(price: 98500, quantity: 1500, rank: 4),
            OrderBookEntry(price: 98000, quantity: 2000, rank: 5),
          ],
          sellOrders: const [
            OrderBookEntry(price: 101000, quantity: 300, rank: 1),
            OrderBookEntry(price: 101500, quantity: 1500, rank: 2),
            OrderBookEntry(price: 102000, quantity: 2000, rank: 3),
            OrderBookEntry(price: 102500, quantity: 1000, rank: 4),
            OrderBookEntry(price: 103000, quantity: 500, rank: 5),
          ],
        ),
      ],
    );
  }
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
        boxShadow: [
          BoxShadow(
            color: extendedColors.neutral500,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
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
                    onPressed: () => ReleaseLockedAmountSheet.show(context),
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
                          final fee =
                              price * quantity * feePct / 100;
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
                              'total': price * quantity + fee,
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
