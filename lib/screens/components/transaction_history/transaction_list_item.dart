import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';

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
  nominal,
  csd
}

class TransactionItem {
  final String title;
  final String date;
  final String amount;
  final bool isPositive;
  final String group;
  final String currencyCode; // "MNT" or "USD"

  const TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isPositive,
    required this.group,
    required this.currencyCode,
  });
}

class TransactionListItem extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionListItem({super.key, required this.transaction});

  bool get isPositive => transaction.isPositive;

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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    transaction.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  transaction.date,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isPositive ? transaction.amount : '-${transaction.amount}',
            style: theme.textTheme.bodyLarge?.copyWith(
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
    Color bgColor;
    if (transaction.isPositive) {
      bgColor = extendedColors.primary100;
    } else {
      bgColor = extendedColors.bgSecondary;
    }

    Widget iconContent;
    if (transaction.group == 'mnt' || transaction.group == 'usd') {
      iconContent = CustomSvgIcon(
        (transaction.currencyCode == 'USD') ? 'currency-dollar' : 'tugrug-01',
        color: transaction.isPositive
            ? extendedColors.primaryMain
            : extendedColors.neutral300,
        size: 22,
      );
    } else if (transaction.group == 'bond') {
      iconContent = CustomSvgIcon(
        'bank-note-01',
        color: transaction.isPositive
            ? extendedColors.primaryMain
            : extendedColors.neutral300,
        size: 22,
      );
    } else {
      // Stock
      iconContent = CustomSvgIcon(
        'coins-swap-02',
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
