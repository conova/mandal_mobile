import 'package:flutter/material.dart';

import '../theme/extended_colors.dart';

enum CustomSnackbarType { success, error, info }

class CustomSnackbar {
  /// API дуудлагын алдааг улаан snackbar-аар харуулна.
  /// Exception-ий "Exception: " угтварыг автоматаар хасна.
  static void showError(BuildContext context, Object error) {
    show(
      context,
      message: error.toString().replaceFirst('Exception: ', ''),
      type: CustomSnackbarType.error,
    );
  }

  static void show(
    BuildContext context, {
    required String message,
    CustomSnackbarType type = CustomSnackbarType.success,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    IconData iconData;
    Color iconColor;

    switch (type) {
      case CustomSnackbarType.success:
        iconData = Icons.check_circle_outline;
        iconColor = extendedColors.primary500;
        break;
      case CustomSnackbarType.error:
        iconData = Icons.cancel_outlined;
        iconColor = colorScheme.error;
        break;
      case CustomSnackbarType.info:
        iconData = Icons.info_outline;
        iconColor = extendedColors.bgBase;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Урвуу (inverse) дэвсгэр — light theme-д бараан, dark-д цайвар
          color: extendedColors.neutral100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.bgBase,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (actionLabel != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        if (onAction != null) onAction();
                      },
                      child: Text(
                        actionLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.primary500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 4),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
