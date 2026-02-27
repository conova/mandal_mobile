import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

enum CustomButtonVariant { primary, secondary, tertiary, text }

enum CustomButtonSize { large, small }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final IconData? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.large,
    this.icon,
    this.isLoading = false,
  });

  bool get isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    // Colors based on variants
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case CustomButtonVariant.primary:
        backgroundColor = theme.primaryColor;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case CustomButtonVariant.secondary:
        backgroundColor = extendedColors.primary200;
        foregroundColor = theme.primaryColor;
        break;
      case CustomButtonVariant.tertiary:
        backgroundColor = extendedColors.bgTertiary;
        foregroundColor = theme.colorScheme.onBackground;
        break;
      case CustomButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.primaryColor;
        break;
    }

    // Adjust for disabled state
    if (isDisabled) {
      backgroundColor = variant == CustomButtonVariant.text
          ? Colors.transparent
          : theme.disabledColor.withOpacity(0.12);
      foregroundColor = theme.disabledColor;
    }

    // Dimensions based on size
    final double height = size == CustomButtonSize.large ? 52 : 40;
    final EdgeInsets padding = size == CustomButtonSize.large
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    final double iconSize = size == CustomButtonSize.large ? 20 : 20;
    final double borderRadius = size == CustomButtonSize.large ? 26 : 20;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (icon != null)
          Icon(icon, size: iconSize, color: foregroundColor),

        if (isLoading || icon != null) const SizedBox(width: 6),

        Flexible(
          child: Text(
            textAlign: TextAlign.center,
            label,
            style: size == CustomButtonSize.large
                ? theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.regular,
                    color: foregroundColor,
                  )
                : theme.textTheme.labelLarge?.copyWith(
                    fontWeight: AppTextStyles.regular,
                    color: foregroundColor,
                  ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
