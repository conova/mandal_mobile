import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import 'components/stock_trading/stock_trading_input_box.dart';
import 'components/stock_trading/stock_trading_quantity_selector.dart';
import 'components/stock_trading/stock_trading_percentage_selector.dart';
import 'components/stock_trading/stock_trading_info_box.dart';
import 'components/stock_trading/stock_trading_order_board.dart';
import 'components/stock_trading/stock_trading_confirmation_overlay.dart';
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
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '65.62');
    _quantityController = TextEditingController(text: '1');
    _priceFocusNode = FocusNode();
    _quantityFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _priceFocusNode.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _showConfirmation() {
    setState(() {
      _isConfirming = true;
    });
  }

  void _hideConfirmation() {
    setState(() {
      _isConfirming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      l10n.limitPrice,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MNDL - ${l10n.buyTab}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: '${l10n.availableCash}: ',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          children: [
                            TextSpan(
                              text: '142,000.53₮',
                              style: TextStyle(
                                color: extendedColors.primaryMain,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1 MNDL = 65.62₮',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      StockTradingInputBox(
                        label: l10n.limitPrice,
                        controller: _priceController,
                        focusNode: _priceFocusNode,
                        suffixText: l10n.paste,
                        onSuffixTap: () {},
                      ),
                      const SizedBox(height: 16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderBoardTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const StockTradingOrderBoard(),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          if (_isConfirming)
            StockTradingConfirmationOverlay(
              onConfirm: () {
                Navigator.pushReplacementNamed(context, '/stock_success');
              },
              onCancel: _hideConfirmation,
            ),
        ],
      ),
      bottomNavigationBar: _isConfirming
          ? null
          : StockTradingBottomBar(
              onPlaceOrder: _showConfirmation,
              onReleaseLocked: () =>
                  Navigator.pushNamed(context, '/release_locked'),
              lockedAmount: '129,341.30₮',
            ),
    );
  }
}
