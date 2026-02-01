import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';

class StockTradingSwipeAction extends StatelessWidget {
  const StockTradingSwipeAction({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: extendedColors.primaryMain,
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
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
