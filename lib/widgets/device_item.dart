import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'custom_button.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              deviceName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomButton(
              onPressed: onRemove,
              label: l10n.remove,
              variant: CustomButtonVariant.error,
              size: CustomButtonSize.small,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.teal[50]?.withOpacity(0.5)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive ? Colors.teal[400] : Colors.black87,
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
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
