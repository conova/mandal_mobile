import 'package:flutter/material.dart';
import '../theme/extended_colors.dart';

/// Хоосон төлвийн нэгдсэн харагдац: дугуй дэвсгэртэй icon, гарчиг,
/// нэмэлт тайлбар. Хайлтын илэрцгүй, хоосон жагсаалт г.м. бүх
/// хоосон төлөвт үүнийг ашиглана.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: extendedColors.neutral100),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 8),
          Text(
            hint!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
        ],
      ],
    );
  }
}
