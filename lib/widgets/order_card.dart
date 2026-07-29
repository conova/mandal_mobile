import 'dart:math';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';

enum OrderType { buy, sell }

enum OrderStatus { open, closed }

enum MarketType { bond, stock, foreign }

class OrderCard extends StatelessWidget {
  final String companyName;
  final String subtitle;
  final String amount;
  final String price;
  final String execution;
  final String date;
  final OrderType type;
  final OrderStatus status;
  final MarketType market;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.companyName,
    required this.subtitle,
    required this.amount,
    required this.price,
    required this.execution,
    required this.date,
    required this.type,
    required this.status,
    required this.market,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerTheme.color ?? theme.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          companyName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: extendedColors.neutral100
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: extendedColors.neutral200
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    amount,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildBadge(
                  theme,
                  type == OrderType.buy ? l10n.buy : l10n.sell,
                  type == OrderType.buy
                      ? theme.primaryColor.withOpacity(0.12)
                      : colorScheme.error.withOpacity(0.12),
                  type == OrderType.buy
                      ? theme.primaryColor
                      : colorScheme.error,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  theme,
                  status == OrderStatus.open ? l10n.open : l10n.closed,
                  colorScheme.surfaceContainerHighest,
                  colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  theme,
                  market == MarketType.bond
                      ? l10n.bond
                      : (market == MarketType.stock
                            ? l10n.stock
                            : l10n.foreign),
                  colorScheme.surfaceContainerHighest,
                  colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              theme,
              type == OrderType.buy ? l10n.unitPrice : l10n.sellingPrice,
              price,
              extendedColors
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.executionQuantity, style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                    fontWeight: FontWeight.w200
                )),
                Row(
                  children: [
                    Text(
                      execution,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(
                          Icons.edit_square,
                          size: 20,
                          color: theme.primaryColor,
                        ),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: theme.textTheme.labelLarge?.copyWith(
                color: extendedColors.neutral200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(
    ThemeData theme,
    String text,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value, extendedColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w200,
                color: extendedColors.neutral200
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: extendedColors.neutral100
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
