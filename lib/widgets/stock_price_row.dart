import 'package:flutter/material.dart';

import 'custom_svg_icon.dart';

class StockPriceRow extends StatelessWidget {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool? isGrowing;
  final VoidCallback? onTap;

  const StockPriceRow({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    this.isGrowing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isGrowing != null && change != '0.00%')
                        CustomSvgIcon(
                          isGrowing!
                              ? 'button-up'
                              : 'button-down',
                          color: isGrowing!
                              ? theme.primaryColor
                              : colorScheme.error,
                          size: 6,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        change,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isGrowing == null || change == '0.00%'
                              ? theme.textTheme.bodySmall?.color ?? Colors.grey
                              : (isGrowing!
                                    ? theme.primaryColor
                                    : colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
