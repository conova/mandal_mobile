import 'package:flutter/material.dart';

enum CustomSnackbarType { success, error, info }

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    CustomSnackbarType type = CustomSnackbarType.success,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData iconData;
    Color iconColor;

    switch (type) {
      case CustomSnackbarType.success:
        iconData = Icons.check_circle_outline;
        iconColor = const Color(0xFF4DB6AC); // Teal matching the design
        break;
      case CustomSnackbarType.error:
        iconData = Icons.cancel_outlined;
        iconColor = colorScheme.error;
        break;
      case CustomSnackbarType.info:
        iconData = Icons.info_outline;
        iconColor = Colors.white;
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
          color: const Color(0xFF1A1A1A), // Dark background as seen in design
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
                        style: const TextStyle(
                          color: Color(0xFF4DB6AC), // Action color
                          fontSize: 14,
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
