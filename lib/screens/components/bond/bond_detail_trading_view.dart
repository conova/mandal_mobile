import 'package:flutter/material.dart';
import 'package:mandal_capital/screens/components/bond/bond_trading_input_box.dart';
import 'package:mandal_capital/screens/components/bond/bond_trading_quantity_selector.dart';
import 'package:mandal_capital/widgets/currency_suffix_formatter.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';
import 'bond_order_board.dart';
import 'bond_payment_details.dart';

/// Хоёрдогч + НЭЭЛТТЭЙ бондын арилжааны дизайн: авах ханш, ширхэг
/// сонгогч, төлбөрийн задаргаа, захиалгын самбар.
class BondDetailTradingView extends StatefulWidget {
  final MarketInstrument? bond;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const BondDetailTradingView({
    super.key,
    required this.bond,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<BondDetailTradingView> createState() => _BondDetailTradingViewState();
}

class _BondDetailTradingViewState extends State<BondDetailTradingView> {
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
  }

  @override
  void didUpdateWidget(BondDetailTradingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the bond data arrives late (initially null), update the price controller
    if (oldWidget.bond == null && widget.bond != null) {
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final price = _currentPrice;
    final quantity = _currentQuantity;
    final total = (price * quantity).toDouble();
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
            widget.onQuantityChanged(newVal);
          },
          onDecrease: () {
            final current = _currentQuantity;
            if (current > 0) {
              final newVal = current - 1;
              _quantityController.text = CurrencySuffixFormatter.format(newVal.toString(), suffix: '');
              widget.onQuantityChanged(newVal);
            }
          },
          onChanged: (val) {
            final q = int.tryParse(val.replaceAll(',', '')) ?? 0;
            widget.onQuantityChanged(q);
          },
        ),
        const SizedBox(height: 24),
        BondPaymentDetails(
          totalPayment: formatStockAmount(total, decimals: 0),
          totalReturn: formatStockAmount(expectedReturn, decimals: 0),
          onDetailsPressed: () {},
        ),
        const SizedBox(height: 32),
        Divider(height: 1, color: extendedColors.neutral500),
        const SizedBox(height: 24),
        // Захиалгын самбар — API байхгүй тул түр демо утгууд
        BondOrderBoard(
          orders: [
            BondOrderEntry(price: 989000, quantity: 21),
            BondOrderEntry(price: 990000, quantity: 12),
            BondOrderEntry(price: 1001000, quantity: 5),
            BondOrderEntry(price: 1002000, quantity: 32),
            BondOrderEntry(price: 1002500, quantity: 52),
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
  final int quantity;

  const BondDetailTradingBottomBar({
    super.key,
    required this.bond,
    required this.quantity,
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
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: extendedColors.primary200),
            child: Row(
              children: [
                CustomSvgIcon('info-circle', color: extendedColors.primaryMain, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l10n.lockedAmountLabel}: 500,000₮',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/release_locked'),
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
                  onPressed: quantity > 0
                      ? () => Navigator.pushNamed(
                    context,
                    '/bond_confirmation',
                    arguments: bond?.raw,
                  )
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
