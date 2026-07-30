import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class OrderDetailSummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const OrderDetailSummaryItem({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: extendedColors.neutral200,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w300,
            color: valueColor ?? extendedColors.neutral100,
          ),
        ),
      ],
    );
  }
}
