import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

class OtpInputField extends StatelessWidget {
  final String value;
  final bool isFocused;
  final bool isError;
  final bool enabled;

  const OtpInputField({
    super.key,
    required this.value,
    this.isFocused = false,
    this.isError = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    Color borderColor;
    if (isError) {
      borderColor = colorScheme.error;
    } else if (isFocused) {
      borderColor = colorScheme.primary;
    } else {
      borderColor = extendedColors.neutral500;
    }

    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isFocused ? 2 : 1),
      ),
      child: Center(
        child: Text(
          value.isEmpty ? '-' : value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
