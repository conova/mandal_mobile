import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../theme/extended_colors.dart';

/// Саарал дугуй дэвсгэртэй back товч — AppBar-ийн leading болон
/// custom толгойнуудад давтагддаг хэв маяг.
class CircleBackButton extends StatelessWidget {
  /// Заагаагүй бол Navigator.pop
  final VoidCallback? onPressed;

  const CircleBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          shape: BoxShape.circle,
        ),
        child: CustomSvgIcon(
          'close-button',
          size: 24,
          color: extendedColors.neutral100,
        ),
      ),
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
}
