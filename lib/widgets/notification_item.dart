import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;
  final IconData icon;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isUnread ? theme.primaryColor.withOpacity(0.05) : Colors.transparent,
          border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: theme.primaryColor, size: 24),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, color: theme.disabledColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
