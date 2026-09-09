import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class BondOrderBoard extends StatelessWidget {
  final List<BondOrderEntry> orders;

  const BondOrderBoard({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.orderBoard,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 16),

        // Header Row (50/50 ratio matching data rows)
        Container(
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  l10n.sellPrice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  l10n.quantityLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // List Items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: index % 2 == 0
                    ? extendedColors.bgBase
                    : extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '${order.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₮',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${order.quantity}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class BondOrderEntry {
  final int price;
  final int quantity;

  BondOrderEntry({required this.price, required this.quantity});
}