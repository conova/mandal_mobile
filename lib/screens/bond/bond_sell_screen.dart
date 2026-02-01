import 'package:flutter/material.dart';
import '../components/bond/bond_price_slider.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_order_board.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';

class BondSellScreen extends StatelessWidget {
  const BondSellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Net Capital',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Нэт Капитал',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.ownedAmountLabel}: 10,000,000₮',
              style: TextStyle(
                color: extendedColors.primaryMain,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildBadge(
              l10n.closed,
              extendedColors.primary100,
              extendedColors.primaryMain,
            ),
            const SizedBox(height: 32),
            BondPriceSlider(
              min: 990000,
              max: 1010000,
              initialValue: 1000000,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            BondQuantitySelector(
              maxQuantity: 10,
              initialQuantity: 1,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            _buildProceedsCard(l10n, extendedColors, theme),
            const SizedBox(height: 24),
            _buildInfoBanner(l10n, extendedColors),
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
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/bond_sell_confirmation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: extendedColors.neutral100,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.placeOrder,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
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
          Text(
            l10n.receivableAmountLabel,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Row(
            children: [
              Text(
                '998,000₮',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
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
              style: TextStyle(
                fontSize: 13,
                color: extendedColors.neutral100,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
