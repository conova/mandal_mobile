import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildBadge(
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
                  status == OrderStatus.open ? l10n.open : l10n.closed,
                  colorScheme.surfaceVariant,
                  colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  market == MarketType.bond
                      ? l10n.bond
                      : (market == MarketType.stock
                            ? l10n.stock
                            : l10n.foreign),
                  colorScheme.surfaceVariant,
                  colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              theme,
              type == OrderType.buy ? l10n.unitPrice : l10n.sellingPrice,
              price,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.executionQuantity,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
                Row(
                  children: [
                    Text(
                      execution,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
            const SizedBox(height: 12),
            Text(
              date,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14)),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
