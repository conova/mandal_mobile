import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../services/auth_service.dart';
import '../widgets/circle_back_button.dart';
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
  bool _isScrolledDown = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchDevices();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!_isScrolledDown) {
        setState(() {
          _isScrolledDown = true;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (_isScrolledDown) {
        setState(() {
          _isScrolledDown = false;
        });
      }
    }
  }

  Future<void> _fetchDevices() async {
    try {
      final auth = context.read<AuthService>();
      final list = await auth.getDevices();
      if (!mounted) return;
      setState(() {
        _devices = list;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeDevice(String deviceId) async {
    try {
      final auth = context.read<AuthService>();
      final message = await auth.deleteDevice(deviceId);
      if (!mounted) return;
      CustomSnackbar.show(context, message: message);
      _fetchDevices(); // refresh
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          type: CustomSnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircleBackButton(),
          ),
        ),
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            l10n.connectedDevices,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  if (_devices.isEmpty)
                    Center(
                      child: Text(
                        l10n.noConnectedDevices,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral100,
                        ),
                      ),
                    )
                  else
                    ..._devices.asMap().entries.map((entry) {
                      final device = entry.value;
                      final deviceId = device['DEVICEID']?.toString() ?? '';
                      final deviceInfo = device['DEVICEINFO']?.toString() ?? '';
                      final lastUpdate = device['LASTUPDATE']?.toString() ?? '';
                      final status = device['STATUS']?.toString() ?? '0';
                      final statusName = device['STATUSNAME']?.toString() ?? '';
                      final ipAddress = device['IPADDRESS']?.toString() ?? '';
                      final isActive = status == '1';

                      // Хүн уншихад тохиромжтой нэр: DEVICEINFO байвал тэр,
                      // үгүй бол DEVICEID-ыг товчилж харуулна
                      final deviceName = deviceInfo.isNotEmpty
                          ? deviceInfo
                          : (deviceId.length > 12
                          ? 'Device ${deviceId.substring(0, 8)}…'
                          : 'Device $deviceId');

                      return Column(
                        children: [
                          DeviceItem(
                            deviceName: deviceName,
                            status: isActive ? l10n.active.toUpperCase() : l10n.inactive.toUpperCase(),
                            isActive: isActive,
                            date: lastUpdate,
                            ip: ipAddress,
                            onRemove: () => _removeDevice(deviceId),
                          ),
                          if (entry.key < _devices.length - 1)
                            const Divider(height: 48),
                        ],
                      );
                    }),
                  const SizedBox(height: 40,),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isScrolledDown
                ? const SizedBox.shrink()
                : SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: extendedColors.bgBase,
                  border: BorderDirectional(top: BorderSide(color: extendedColors.neutral500)),
                ),
                child: Text(
                  l10n.connectedDevicesDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
