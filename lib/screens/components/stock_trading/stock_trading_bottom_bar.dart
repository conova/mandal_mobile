import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/locked_amount_bottom_sheet.dart';

class StockTradingBottomBar extends StatelessWidget {
  final VoidCallback onPlaceOrder;
  final VoidCallback onReleaseLocked;
  final String lockedAmount;

  const StockTradingBottomBar({
    super.key,
    required this.onPlaceOrder,
    required this.onReleaseLocked,
    required this.lockedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LockedAmountBottomSheet(
          amount: lockedAmount,
          onRelease: onReleaseLocked,
        ),
        Container(
          padding: const EdgeInsets.all(24),
          color: theme.colorScheme.surface,
          child: SafeArea(
            bottom: true,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: extendedColors.primaryMain,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.placeOrder,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
