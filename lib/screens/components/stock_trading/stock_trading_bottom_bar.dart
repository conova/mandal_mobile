import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/locked_amount_bottom_sheet.dart';

class StockTradingBottomBar extends StatelessWidget {
  final VoidCallback? onPlaceOrder;
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LockedAmountBottomSheet(
          amount: lockedAmount,
          onRelease: onReleaseLocked,
        ),
        Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              bottom: true,
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.placeOrder,
                  onPressed: onPlaceOrder,
                ),
              ),
            )
        ),
      ],
    );
  }
}
