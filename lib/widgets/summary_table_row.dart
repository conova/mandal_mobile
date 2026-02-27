import 'package:flutter/material.dart';

class SummaryTableRow extends StatelessWidget {
  final String label;
  final String val1;
  final String val2;
  final bool isHeader;

  const SummaryTableRow({
    super.key,
    required this.label,
    required this.val1,
    this.val2 = '',
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHeader
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: isHeader ? BorderRadius.circular(12) : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              val1,
              textAlign: TextAlign.right,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? colorScheme.onSurface : colorScheme.onSurface,
              ),
            ),
          ),
          if (val2.isNotEmpty)
            Expanded(
              flex: 3,
              child: Text(
                val2,
                textAlign: TextAlign.right,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: isHeader
                      ? colorScheme.onSurface
                      : colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
