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
      onPressed: onPressed ?? () => Navigator.pop(context),
      style: IconButton.styleFrom(
        backgroundColor: extendedColors.bgSecondary,
        foregroundColor: extendedColors.neutral100,
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
      ),
      icon: const CustomSvgIcon(
        'close-button',
        size: 24,
      ),
    );
  }
}
