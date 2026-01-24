import 'package:flutter/material.dart';

class AssetCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool isDark;

  const AssetCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.onSurface : theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDark ? colorScheme.surface : Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
                ),
                Text(
                  subtitle, 
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount, 
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
