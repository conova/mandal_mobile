import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

import '../../../widgets/custom_svg_icon.dart';

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

  bool _isSectionSelected(int sectionIndex) {
    if (sectionIndex < 0 ||
        sectionIndex >= items.length ||
        items[sectionIndex]['isSection'] != true) {
      return false;
    }

    int childCount = 0;
    int selectedChildCount = 0;

    for (int i = sectionIndex + 1; i < items.length; i++) {
      if (items[i]['isSection'] == true) break;
      childCount++;
      if (selectedIndices.contains(i)) {
        selectedChildCount++;
      }
    }

    return childCount > 0 && childCount == selectedChildCount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSection = item['isSection'] ?? false;

        if (isSection) {
          final isSelected = _isSectionSelected(index);
          return Column(
            children: [
              if (index > 0) ...[
                Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
                const SizedBox(height: 10,),
              ],
              GestureDetector(
                onTap: () => onToggle(index),
                child: Container(
                  color: isSelected ? extendedColors.primary100 : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Section Checkbox
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? extendedColors.primaryMain
                                    : extendedColors.neutral400,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              color: isSelected
                                  ? extendedColors.primaryMain
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Padding(
                              padding: EdgeInsets.all(3),
                              child: CustomSvgIcon('checked',
                                  size: 18, color: Colors.white),
                            )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['title'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: AppTextStyles.bold,
                                    color: extendedColors.neutral100,
                                  ),
                                ),
                                if (item['amount'] != null)
                                  Text(
                                    '${item['amount'].toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}₮',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: AppTextStyles.bold,
                                      color: extendedColors.neutral100,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ]
          );
        }

        final isSelected = selectedIndices.contains(index);

        return GestureDetector(
          onTap: () => onToggle(index),
          child: Container(
            color: isSelected ? extendedColors.primary100 : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          : extendedColors.neutral400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected
                        ? extendedColors.primaryMain
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Padding(
                          padding: EdgeInsets.all(3),
                          child: CustomSvgIcon('checked',
                              size: 18, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Title & subtitle
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          item['title'],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: AppTextStyles.light,
                            color: extendedColors.neutral100,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item['subtitle'] != null &&
                          item['subtitle'].isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item['subtitle'],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: AppTextStyles.light,
                              color: extendedColors.neutral200,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Amount
                Text(
                  '${item['amount'].toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}₮',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.regular,
                    color: isSelected
                        ? extendedColors.neutral100
                        : extendedColors.neutral200,
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
