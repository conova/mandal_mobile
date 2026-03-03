import 'package:flutter/material.dart';
import '../components/bond/bond_confirmation_details.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';

class BondSellConfirmationScreen extends StatelessWidget {
  const BondSellConfirmationScreen({super.key});

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
      body: Padding(
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
            const SizedBox(height: 48),
            BondConfirmationDetails(
              name: 'Net Capital',
              type: l10n.closed,
              quantity: '10',
              unitPrice: '991,000₮',
              commission: '5,000₮',
              total: '9,915,000₮',
            ),
          ],
        ),
      ),
      bottomSheet: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < -100) {
            Navigator.pushNamed(context, '/bond_sell_success');
          }
        },
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: extendedColors.neutral100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.keyboard_double_arrow_up,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.swipeUpToConfirm,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
