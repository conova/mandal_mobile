import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import 'custom_svg_icon.dart';

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
    final extendedColors = theme.extension<ExtendedColors>()!;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerTheme.color ?? extendedColors.neutral500,
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
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                            color: extendedColors.neutral200,
                            fontWeight: FontWeight.w300,
                            fontSize: 13
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
                      ? extendedColors.primary100
                      : AppColors.redMain.withOpacity(0.12),
                  type == OrderType.buy
                      ? extendedColors.primaryMain
                      : AppColors.redMain,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  theme,
                  status == OrderStatus.open ? l10n.open : l10n.closed,
                  extendedColors.bgSecondary,
                  extendedColors.neutral100,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  theme,
                  market == MarketType.bond
                      ? l10n.bond
                      : (market == MarketType.stock
                            ? l10n.stock
                            : l10n.foreign),
                  extendedColors.bgSecondary,
                  extendedColors.neutral100,
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
                  fontWeight: FontWeight.w200,
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
                        icon: CustomSvgIcon(
                          'edit',
                          size: 20,
                          color: extendedColors.primaryMain,
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
                fontWeight: FontWeight.w300
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
              color: extendedColors.neutral200,
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
              color: extendedColors.neutral100,
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
