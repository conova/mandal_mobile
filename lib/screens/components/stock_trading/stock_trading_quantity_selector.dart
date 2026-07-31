import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class StockTradingQuantitySelector extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<String> onChanged;

  const StockTradingQuantitySelector({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onIncrease,
    required this.onDecrease,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: extendedColors.neutral500),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quantityLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral200,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onChanged,
                  ),
                ),
                Row(
                  children: [
                    _buildCircleButton('minus', onDecrease, extendedColors),
                    const SizedBox(width: 8),
                    _buildCircleButton('plus', onIncrease, extendedColors),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
    String icon,
    VoidCallback onTap,
    ExtendedColors extendedColors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomSvgIcon(icon, size: 20, color: extendedColors.neutral100),
      ),
    );
  }
}
