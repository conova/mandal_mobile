import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

class ReleaseLockedAmountList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Set<int> selectedIndices;
  final ValueChanged<int> onToggle;

  const ReleaseLockedAmountList({
    super.key,
    required this.items,
    required this.selectedIndices,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedIndices.contains(index);

        return GestureDetector(
          onTap: () => onToggle(index),
          child: Container(
            color: isSelected
                ? extendedColors.primary100.withValues(alpha: 0.3)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? extendedColors.primaryMain
                          : extendedColors.neutral500,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected
                        ? extendedColors.primaryMain
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),

                // Title & subtitle
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        item['title'],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100,
                        ),
                      ),
                      if (item['subtitle'] != null &&
                          item['subtitle'].isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          item['subtitle'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: AppTextStyles.light,
                            color: extendedColors.neutral400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount
                Text(
                  '${item['amount'].toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}₮',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.regular,
                    color: extendedColors.neutral300,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
