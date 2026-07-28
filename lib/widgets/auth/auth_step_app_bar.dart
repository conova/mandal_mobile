import 'package:flutter/material.dart';

import '../../theme/extended_colors.dart';
import '../circle_back_button.dart';

class AuthStepAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? stepText;
  final VoidCallback? onBack;

  const AuthStepAppBar({super.key, this.stepText, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return AppBar(
      backgroundColor: extendedColors.bgBase,
      elevation: 0,
      toolbarHeight: 70,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircleBackButton(),
        ),
      ),
      actions: [
        if (stepText != null)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 22, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                stepText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
