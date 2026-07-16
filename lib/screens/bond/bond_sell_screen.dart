import 'package:flutter/material.dart';
import '../components/bond/bond_price_slider.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_order_board.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_button.dart';

class BondSellScreen extends StatefulWidget {
  const BondSellScreen({super.key});

  @override
  State<BondSellScreen> createState() => _BondSellScreenState();
}

class _BondSellScreenState extends State<BondSellScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: extendedColors.neutral100),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Net Capital',
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
                    'Нэт Капитал',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.ownedAmountLabel}: 10,000,000₮',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.primaryMain,
                fontWeight: AppTextStyles.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBadge(
              l10n.closed,
              extendedColors.primary100,
              extendedColors.primaryMain,
              theme,
            ),
            const SizedBox(height: 32),
            BondPriceSlider(
              min: 990000,
              max: 1010000,
              initialValue: 1000000,
              // Сонгосон үнэ одоогоор хаана ч ашиглагддаггүй (демо дэлгэц)
              onChanged: (_) {},
            ),
            const SizedBox(height: 24),
            BondQuantitySelector(
              maxQuantity: 10,
              initialQuantity: 1,
              onChanged: (value) {
                setState(() {
                  _quantity = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildProceedsCard(l10n, extendedColors, theme),
            const SizedBox(height: 24),
            _buildInfoBanner(l10n, extendedColors, theme),
            const SizedBox(height: 32),
            BondOrderBoard(
              orders: [
                BondOrderEntry(price: 993000, quantity: 50),
                BondOrderEntry(price: 994000, quantity: 24),
                BondOrderEntry(price: 1005000, quantity: 20),
                BondOrderEntry(price: 1010000, quantity: 10),
              ],
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
            onPressed: _quantity > 0
                ? () =>
                    Navigator.pushNamed(context, '/bond_sell_confirmation')
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildProceedsCard(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    return Container(
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
              l10n.receivableAmountLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral400,
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
                    '998,000₮',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: extendedColors.neutral100,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: extendedColors.primary100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: extendedColors.neutral100,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.sellPriceDesc,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    String label,
    Color bgColor,
    Color textColor,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
