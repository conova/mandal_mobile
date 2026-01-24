import 'package:flutter/material.dart';

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
          style: TextStyle(color: theme.disabledColor, fontSize: 15),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
