import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class DeviceItem extends StatelessWidget {
  final String deviceName;
  final String status;
  final bool isActive;
  final String date;
  final String ip;
  final VoidCallback? onRemove;

  const DeviceItem({
    super.key,
    required this.deviceName,
    required this.status,
    required this.isActive,
    required this.date,
    required this.ip,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                deviceName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onRemove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error.withOpacity(0.1),
                  foregroundColor: colorScheme.error,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  l10n.remove,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? extendedColors.primary100
                : extendedColors.neutral100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? extendedColors.primaryMain
                  : extendedColors.neutral300,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.date,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: extendedColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ipAddress,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: extendedColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(ip, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
