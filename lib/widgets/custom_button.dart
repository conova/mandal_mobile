import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

enum CustomButtonVariant { primary, secondary, tertiary, text, error, neutral, purple, orange }

enum CustomButtonSize { large, small }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final Widget? icon;
  final bool isLoading;

  /// Товчны хамгийн бага өргөн (заагаагүй бол агуулгаараа хэмжигдэнэ)
  final double? minWidth;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.minWidth,
  });

  bool get isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    // Colors based on variants
    Color backgroundColor;
    Color foregroundColor;

    switch (variant) {
      case CustomButtonVariant.primary:
        backgroundColor = theme.primaryColor;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case CustomButtonVariant.secondary:
        backgroundColor = extendedColors.primary100;
        foregroundColor = theme.primaryColor;
        break;
      case CustomButtonVariant.tertiary:
        backgroundColor = extendedColors.bgSecondary;
        foregroundColor = extendedColors.neutral100;
        break;
      case CustomButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.primaryColor;
        break;
      case CustomButtonVariant.error:
        backgroundColor = extendedColors.red100;
        foregroundColor = extendedColors.red;
      case CustomButtonVariant.neutral:
        backgroundColor = extendedColors.neutral100;
        foregroundColor = extendedColors.bgBase;
      case CustomButtonVariant.purple:
        backgroundColor = extendedColors.purple;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case CustomButtonVariant.orange:
        backgroundColor = extendedColors.orange;
        foregroundColor = theme.colorScheme.onPrimary;
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
        : const EdgeInsets.symmetric(horizontal: 0, vertical: 10);
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
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (icon != null)
          IconTheme.merge(
            data: IconThemeData(
              size: iconSize,
              color: foregroundColor,
            ),
            child: icon!,
          ),

        if (isLoading || icon != null) const SizedBox(width: 4),

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

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height,
        maxHeight: height,
        minWidth: minWidth ?? 0,
      ),
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
