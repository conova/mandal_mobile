import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        border: BorderDirectional(
          top: BorderSide(color: extendedColors.neutral500, width: 1),
        )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lockedAmount != '0₮')
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
      ),
    );
  }
}
