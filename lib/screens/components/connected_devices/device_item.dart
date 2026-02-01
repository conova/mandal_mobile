import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onRemove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50]?.withOpacity(0.5),
                  foregroundColor: Colors.red[400],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  l10n.remove,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                ? Colors.teal[50]?.withOpacity(0.5)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isActive ? Colors.teal[400] : Colors.black87,
              fontSize: 12,
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
                    style: TextStyle(color: theme.disabledColor, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ipAddress,
                    style: TextStyle(color: theme.disabledColor, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(ip, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
