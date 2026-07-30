import 'package:flutter/material.dart';

import '../../../theme/extended_colors.dart';

class StockTradingPercentageSelector extends StatelessWidget {
  final ValueChanged<String>? onPercentageSelected;

  const StockTradingPercentageSelector({super.key, this.onPercentageSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentages = ['25%', '50%', '75%', '100%'];
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: percentages.map((p) {
        return TextButton(
          onPressed: () => onPercentageSelected?.call(p),
          child: Text(
            p,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
        );
      }).toList(),
    );
  }
}
