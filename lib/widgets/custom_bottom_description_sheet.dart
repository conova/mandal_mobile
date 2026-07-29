import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';

import '../theme/extended_colors.dart';

class CustomBottomDescriptionSheet extends StatelessWidget {
  final String title;
  final String description;
  final String cancelText;
  final VoidCallback onCancel;
  final String? icon;
  final Color? confirmColor;
  final CustomButtonVariant? buttonVariant;

  const CustomBottomDescriptionSheet({
    super.key,
    required this.title,
    required this.description,
    required this.cancelText,
    required this.onCancel,
    this.icon,
    this.confirmColor,
    this.buttonVariant
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
              Container(
                padding: EdgeInsets.all(20),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: extendedColors.bgSecondary,
                  shape: BoxShape.circle,
                ),
                child: CustomSvgIcon(icon ?? 'info-circle', size: 20, color: extendedColors.neutral100,),
              ),
            const SizedBox(height: 24,),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: extendedColors.neutral100,
                  fontSize: 14,
                  fontFamily: 'Geologica',
                ),
              ),
            ),
            const SizedBox(height: 26),
            CustomButton(
              label: cancelText,
              onPressed: onCancel,
              variant: buttonVariant ?? CustomButtonVariant.tertiary,
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}
