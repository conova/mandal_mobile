import 'package:flutter/material.dart';
import '../theme/extended_colors.dart';

/// Доогуураа богино зураастай хэсгийн гарчиг ("Анхдагч арилжаа",
/// "Миний бонд" г.м.) — олон дэлгэцэд давтагддаг хэв маяг.
class SectionTitle extends StatelessWidget {
  final String title;
  final bool isPrimary;

  /// Доогуур зураасны өнгө — заагаагүй бол primaryMain
  final Color? underlineColor;

  const SectionTitle(
    this.title,
    this.isPrimary,
    {
      super.key,
      this.underlineColor,
    }
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isPrimary) ...[
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: extendedColors.primary100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: underlineColor ?? extendedColors.primaryMain,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
        ] else ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: underlineColor ?? extendedColors.primaryMain,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
      ],
    );
  }
}
