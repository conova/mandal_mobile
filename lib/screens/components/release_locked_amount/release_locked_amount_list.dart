import 'package:flutter/material.dart';
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
        final isSection = item['isSection'] as bool;

        if (isSection) {
          // The original code didn't handle isSection logic explicitly in rendering except for calculating total?
          // Wait, looking at original code:
          /*
                final item = _items[index];
                final isSelected = _selectedIndices.contains(index);

                return GestureDetector(...)
            */
          // It just renders everything as selectable rows?
          // "item['title']" is used.
          // Let's check the original code again.
          // "if (!_items[index]['isSection']) { total += ... }"
          // But in UI, isSection items are also selectable?
          // The logic implies they are just items in the list.
          // The subtitle might be empty.
          // I'll render them as is.
        }

        return GestureDetector(
          onTap: () => onToggle(index),
          child: Container(
            color: isSelected
                ? extendedColors.primary100.withOpacity(0.3)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? extendedColors.primaryMain
                          : theme.dividerColor,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item['subtitle'] != null &&
                              item['subtitle'].isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              item['subtitle'],
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item['amount'].toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}₮',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
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
