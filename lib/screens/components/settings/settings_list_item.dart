import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';

class SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showArrow;

  const SettingsListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.onSurface, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: extendedColors.neutral100,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: extendedColors.neutral200,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) trailing!,
            if (trailing != null && showArrow) const SizedBox(width: 8),
            if (showArrow)
              CustomSvgIcon(
                'chevron-right',
                size: 24,
                color: extendedColors.neutral200,
              ),
          ],
        ),
      ),
    );
  }
}
