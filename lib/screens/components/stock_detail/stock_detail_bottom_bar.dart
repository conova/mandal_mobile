import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:mandal_capital/widgets/currency_suffix_formatter.dart';
import '../../../l10n/app_localizations.dart';

class StockDetailBottomBar extends StatelessWidget {
  final VoidCallback onTrade;

  /// Арилжааны цэс (Авах/Зарах) нээлттэй үед товч ✕ болж хувирна
  final bool isMenuOpen;

  final double? availableCash;

  const StockDetailBottomBar({
    super.key,
    required this.onTrade,
    this.isMenuOpen = false,
    this.availableCash,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 10, left: 24, right: 24),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cash,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  availableCash != null
                      ? CurrencySuffixFormatter.format(availableCash.toString(),
                          suffix: '₮')
                      : '...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: extendedColors.primaryMain,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            isMenuOpen
                // Цэс нээлттэй — хаах (✕) товч
                ? SizedBox(
                    height: 52,
                    width: 200,
                    child: TextButton(
                      onPressed: onTrade,
                      style: TextButton.styleFrom(
                        backgroundColor: extendedColors.bgSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: extendedColors.neutral100,
                        size: 24,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 52,
                    width: 200,
                    child: CustomButton(
                      label: l10n.trade,
                      onPressed: onTrade,
                      size: CustomButtonSize.large,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
