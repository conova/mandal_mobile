import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../widgets/custom_snackbar.dart';

import 'components/connected_devices/device_item.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(ApiConfig.devices);
      final body = response.data;

      if (mounted && body['code']?.toString() == '0' && body['data'] != null) {
        final devicesData = body['data'] as List;
        setState(() {
          _devices = devicesData
              .map((d) => Map<String, dynamic>.from(d))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeDevice(String deviceId) async {
    try {
      final apiService = context.read<ApiService>();
      await apiService.delete('${ApiConfig.devices}/$deviceId');

      if (mounted) {
        CustomSnackbar.show(context, message: 'Төхөөрөмж устгагдлаа');
        _fetchDevices(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Устгахад алдаа: ${e.toString()}',
          type: CustomSnackbarType.error,
        );
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  if (_devices.isEmpty)
                    Center(
                      child: Text(
                        'Бүртгэлтэй төхөөрөмж байхгүй',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral500,
                        ),
                      ),
                    )
                  else
                    ..._devices.asMap().entries.map((entry) {
                      final device = entry.value;
                      final deviceId = device['DEVICEID']?.toString() ?? '';
                      final lastUpdate = device['LASTUPDATE']?.toString() ?? '';
                      final status = device['STATUS']?.toString() ?? '0';
                      final statusName = device['STATUSNAME']?.toString() ?? '';
                      final isActive = status == '1';

                      return Column(
                        children: [
                          DeviceItem(
                            deviceName: 'Device $deviceId',
                            status: statusName.isNotEmpty
                                ? statusName
                                : (isActive ? l10n.active : l10n.inactive),
                            isActive: isActive,
                            date: lastUpdate,
                            ip: '',
                            onRemove: () => _removeDevice(deviceId),
                          ),
                          if (entry.key < _devices.length - 1)
                            const Divider(height: 48),
                        ],
                      );
                    }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
