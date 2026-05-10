import 'package:flutter/material.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_payment_details.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_button.dart';

class BondBuyScreen extends StatefulWidget {
  const BondBuyScreen({super.key});

  @override
  State<BondBuyScreen> createState() => _BondBuyScreenState();
}

class _BondBuyScreenState extends State<BondBuyScreen> {
  int _quantity = 0;

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
              '${l10n.availableCash}: 10,000,000₮',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.primaryMain,
                fontWeight: AppTextStyles.bold,
              ),
            ),
            const SizedBox(height: 32),
            BondQuantitySelector(
              maxQuantity: 8000,
              onChanged: (quantity) {
                setState(() {
                  _quantity = quantity;
                });
              },
            ),
            const SizedBox(height: 24),
            BondPaymentDetails(
              totalPayment: '1,001,000₮',
              totalReturn: '190,000₮',
              onDetailsPressed: () {
                // Show more details
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
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
                    Icon(
                      Icons.info,
                      color: extendedColors.neutral100,
                      size: 24,
                    ),
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
                    Icon(
                      Icons.expand_less,
                      color: extendedColors.neutral100,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: l10n.placeOrder,
                onPressed: _quantity > 0
                    ? () =>
                        Navigator.pushNamed(context, '/bond_confirmation')
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
