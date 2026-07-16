import 'package:flutter/material.dart';
import '../theme/extended_colors.dart';

/// Доогуураа богино зураастай хэсгийн гарчиг ("Анхдагч арилжаа",
/// "Миний бонд" г.м.) — олон дэлгэцэд давтагддаг хэв маяг.
class SectionTitle extends StatelessWidget {
  final String title;

  /// Доогуур зураасны өнгө — заагаагүй бол primaryMain
  final Color? underlineColor;

  const SectionTitle(this.title, {super.key, this.underlineColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: underlineColor ?? extendedColors.primaryMain,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
