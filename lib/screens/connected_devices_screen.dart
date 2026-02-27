import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';

import 'components/connected_devices/device_item.dart';

class ConnectedDevicesScreen extends StatelessWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.connectedDevices,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.connectedDevicesDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral500,
              ),
            ),
            const SizedBox(height: 32),
            DeviceItem(
              deviceName: 'IOS iPhone 15 Pro max',
              status: l10n.active,
              isActive: true,
              date: '2025.10.10 13:55:32',
              ip: '122.201.31.180',
              onRemove: () {},
            ),
            const Divider(height: 48),
            DeviceItem(
              deviceName: 'IOS iPhone 11',
              status: l10n.inactive,
              isActive: false,
              date: '2025.10.10 13:55:32',
              ip: '122.201.31.180',
              onRemove: () {},
            ),
            const Divider(height: 48),
            DeviceItem(
              deviceName: 'Android S24',
              status: l10n.inactive,
              isActive: false,
              date: '2025.10.10 13:55:32',
              ip: '122.201.31.180',
              onRemove: () {},
            ),
            const Divider(height: 48),
          ],
        ),
      ),
    );
  }
}
