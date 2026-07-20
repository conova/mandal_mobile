import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../../../l10n/app_localizations.dart';

class StockDetailHeader extends StatelessWidget {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool? isGrowing;

  const StockDetailHeader({
    super.key,
    this.symbol = '',
    this.name = '',
    this.price = '-',
    this.change = '-',
    this.isGrowing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final changeColor = isGrowing == null
        ? extendedColors.neutral200
        : (isGrowing! ? extendedColors.primaryMain : theme.colorScheme.error);
    final showArrow = isGrowing != null && change != '0.00%' && change != '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            symbol,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            price,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          Row(
            children: [
              if (showArrow)
                CustomSvgIcon(
                  isGrowing!
                      ? 'button-up'
                      : 'button-down',
                  color: changeColor,
                  size: 6,
                ),
              const SizedBox(width: 4,),
              Text(
                change,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.today,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
