import 'package:flutter/material.dart';
import '../theme/extended_colors.dart';

class SummaryTableRow extends StatelessWidget {
  final String label;
  final String val1;
  final String val2;
  final bool isOdd;
  final bool? isLast;

  const SummaryTableRow({
    super.key,
    required this.label,
    required this.val1,
    this.val2 = '',
    this.isOdd = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final isLast = this.isLast ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOdd
            ? isLast
                ? extendedColors.primaryMain
                : extendedColors.bgSecondary
            : extendedColors.bgBase,
        borderRadius: isOdd ? BorderRadius.circular(12) : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isLast
                  ? extendedColors.bgBase
                  : extendedColors.neutral100,
            ),
          ),
          Expanded(
            child: Text(
              val1,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isLast
                    ? extendedColors.bgBase
                    : extendedColors.neutral100,
              ),
            ),
          ),
          if (val2.isNotEmpty)
            Expanded(
              child: Text(
                val2,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLast
                      ? extendedColors.bgBase
                      : extendedColors.neutral100,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
