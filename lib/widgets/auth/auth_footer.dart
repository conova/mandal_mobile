import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';

class AuthFooter extends StatelessWidget {
  final String questionText;
  final String actionText;
  final VoidCallback onAction;

  const AuthFooter({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          questionText,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: AppTextStyles.regular,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTextStyles.regular,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
