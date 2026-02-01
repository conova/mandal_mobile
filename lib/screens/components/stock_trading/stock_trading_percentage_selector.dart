import 'package:flutter/material.dart';

class StockTradingPercentageSelector extends StatelessWidget {
  final ValueChanged<String>? onPercentageSelected;

  const StockTradingPercentageSelector({super.key, this.onPercentageSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentages = ['25%', '50%', '75%', '100%'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: percentages.map((p) {
        return TextButton(
          onPressed: () => onPercentageSelected?.call(p),
          child: Text(
            p,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
    );
  }
}
