import 'package:flutter/material.dart';

class StockPriceRow extends StatelessWidget {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool isGrowing;
  final VoidCallback? onTap;

  const StockPriceRow({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    this.isGrowing = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (change != '0.00%')
                      Icon(
                        isGrowing ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: isGrowing ? theme.primaryColor : colorScheme.error,
                        size: 20,
                      ),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: change == '0.00%' 
                          ? theme.textTheme.bodySmall?.color ?? Colors.grey 
                          : (isGrowing ? theme.primaryColor : colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
