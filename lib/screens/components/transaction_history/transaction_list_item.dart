import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

enum FilterTag {
  cashIncome,
  cashExpense,
  bondBought,
  bondSold,
  bondReturn,
  stockBought,
  stockSold,
  stockDividend,
  stockTransfer,
}

class TransactionItem {
  final String title;
  final String date;
  final String amount;
  final bool isPositive;
  final FilterTag tag;
  final String currencyCode; // "MNT" or "USD"

  const TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isPositive,
    required this.tag,
    required this.currencyCode,
  });
}

class TransactionListItem extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildIcon(extendedColors),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: extendedColors.neutral100,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: extendedColors.neutral300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            transaction.amount,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: transaction.isPositive
                  ? extendedColors.primaryMain
                  : extendedColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(ExtendedColors extendedColors) {
    final isCash = transaction.tag == FilterTag.cashIncome ||
        transaction.tag == FilterTag.cashExpense;
    final isBond = transaction.tag == FilterTag.bondBought ||
        transaction.tag == FilterTag.bondSold ||
        transaction.tag == FilterTag.bondReturn;

    Color bgColor;
    if (transaction.isPositive) {
      bgColor = extendedColors.primary100.withValues(alpha: 0.3);
    } else {
      bgColor = extendedColors.bgSecondary;
    }

    Widget iconContent;
    if (isCash) {
      final symbol = transaction.currencyCode == 'USD' ? '\$' : '₮';
      iconContent = Text(
        symbol,
        style: TextStyle(
          color: transaction.isPositive
              ? extendedColors.primaryMain
              : extendedColors.neutral300,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (isBond) {
      iconContent = Icon(
        Icons.description_outlined,
        color: transaction.isPositive
            ? extendedColors.primaryMain
            : extendedColors.neutral300,
        size: 22,
      );
    } else {
      // Stock
      iconContent = Icon(
        Icons.show_chart,
        color: transaction.isPositive
            ? extendedColors.primaryMain
            : extendedColors.neutral300,
        size: 22,
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: iconContent),
    );
  }
}
