import 'package:flutter/material.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_payment_details.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';

class BondBuyScreen extends StatelessWidget {
  const BondBuyScreen({super.key});

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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Нэт Капитал',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.availableCash}: 10,000,000₮',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.primaryMain,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            BondQuantitySelector(
              maxQuantity: 8000,
              onChanged: (quantity) {
                // Handle quantity change
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
            const SizedBox(height: 120), // Bottom bar space
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                        fontWeight: FontWeight.w500,
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/bond_confirmation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: extendedColors.neutral100,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.placeOrder,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
