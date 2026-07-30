import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';

import '../theme/extended_colors.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String? icon;
  final Color? confirmColor;
  final CustomButtonVariant? buttonVariantTop;
  final CustomButtonVariant? buttonVariantBottom;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    this.icon,
    this.confirmColor,
    this.buttonVariantTop,
    this.buttonVariantBottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: extendedColors.bgBase,
          boxShadow: [
            BoxShadow(
              color: extendedColors.neutral400,
              offset: Offset(0, -4),
              blurRadius: 40,
            )
          ]
      ),
      // Жижиг дэлгэц/keyboard үед агуулга багтахгүй бол scroll болно
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: extendedColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            if (icon != null)
              Image.asset(icon ?? 'assets/images/log_out.png', height: 130),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: confirmText,
                onPressed: onConfirm,
                variant: buttonVariantTop ?? CustomButtonVariant.red,
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: cancelText,
              onPressed: onCancel,
              variant: buttonVariantBottom ?? CustomButtonVariant.tertiary,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
