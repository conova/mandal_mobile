import 'package:flutter/material.dart';
import '../theme/extended_colors.dart';

class NotificationFilterChipBar extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final double horizontalPadding;

  const NotificationFilterChipBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.horizontalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0,),
            child: ChoiceChip(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterSelected(filter);
                }
              },
              selectedColor: extendedColors.neutral100,
              avatarBorder: Border.all(
                color: extendedColors.neutral500,
                width: 1,
              ),
              backgroundColor: extendedColors.bgSecondary,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? extendedColors.bgBase
                    : extendedColors.neutral200,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide.none,
              ),
              side: BorderSide(
                color: Colors.transparent,
                width: 1,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
