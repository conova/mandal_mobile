import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../theme/extended_colors.dart';
import 'bond_order_board.dart';
import 'bond_payment_details.dart';
import 'bond_quantity_selector.dart';

/// Хоёрдогч + НЭЭЛТТЭЙ бондын арилжааны дизайн: авах ханш, ширхэг
/// сонгогч, төлбөрийн задаргаа, захиалгын самбар.
class BondDetailTradingView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final price = bond?.closePrice ?? bond?.openPrice ?? 0;
    final total = price * quantity;
    final rate = bond?.intRate ?? 0;
    final expectedReturn = total * rate / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Авах ханш
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: extendedColors.bgBase,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: extendedColors.neutral500),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.buyRate,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: extendedColors.neutral300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatStockAmount(price, decimals: 0),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BondQuantitySelector(
          maxQuantity: 8000,
          onChanged: onQuantityChanged,
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
      padding: const EdgeInsets.all(24),
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
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/release_locked'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: extendedColors.primary100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: extendedColors.neutral100, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${l10n.lockedAmountLabel}: 500,000₮',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTextStyles.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                  Text(
                    l10n.release,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: extendedColors.neutral100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.expand_less, color: extendedColors.neutral100),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
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
        ],
      ),
    );
  }
}
