import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_state_manager.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/language_switcher.dart';
import '../widgets/logout_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'components/profile/profile_header.dart';
import 'components/profile/profile_list_item.dart';
import 'components/profile/profile_toggle_item.dart';
import 'components/profile/profile_section_header.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userPhone = '';
  String? _passDate; // Сүүлийн нууц үг солисон огноо
  int? _deviceCount; // Холбогдсон төхөөрөмжийн тоо
  bool _biometricBusy = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _handleBiometricToggle(bool requested) async {
    if (_biometricBusy) return;
    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context)!;

    setState(() => _biometricBusy = true);
    try {
      if (requested) {
        // Идэвхжүүлэхээс өмнө биометрикийг шалгах
        final available = await auth.getAvailableBiometrics();
        if (available.isEmpty) {
          if (mounted) {
            CustomSnackbar.show(
              context,
              message: 'Биометрик уншигч олдсонгүй',
              type: CustomSnackbarType.error,
            );
          }
          return;
        }
        final ok = await auth.authenticateWithBiometrics();
        if (!ok) {
          if (mounted) {
            CustomSnackbar.show(
              context,
              message: 'Биометрик баталгаажуулалт амжилтгүй',
              type: CustomSnackbarType.error,
            );
          }
          return;
        }
        await auth.setBiometricEnabled(true);
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: '${l10n.biometric} ${l10n.active.toLowerCase()}',
            type: CustomSnackbarType.success,
          );
        }
      } else {
        await auth.setBiometricEnabled(false);
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: '${l10n.biometric} ${l10n.inactive.toLowerCase()}',
            type: CustomSnackbarType.info,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Алдаа: $e',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(ApiConfig.userInfo);
      final body = response.data;

      if (mounted && body['code']?.toString() == '0' && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        setState(() {
          _userName = data['firstName']?.toString() ?? '';
          _userPhone = data['phone']?.toString() ?? '';
          _passDate = _formatPassDate(data['passDate']?.toString());
          _deviceCount = int.tryParse(data['deviceCount']?.toString() ?? '');
        });
      }
    } catch (_) {
      // Fallback: token-оос авсан нэрийг ашиглана
      if (mounted) {
        final authService = context.read<AuthService>();
        setState(() {
          _userName = authService.custName ?? '';
        });
      }
    }
  }

  /// passDate-г "2025.10.20" форматад хөрвүүлнэ.
  /// Сервер "2025-10-20", "2025-10-20 14:30:00" гэх мэт форматаар илгээж
  /// болзошгүй тул зөвхөн огнооны хэсгийг авч цэгээр форматлана.
  String? _formatPassDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final datePart = raw.split(RegExp(r'[ T]')).first;
    return datePart.replaceAll('-', '.');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final biometricEnabled = context.watch<AuthService>().isBiometricEnabled;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        // M3 default-аар scroll болоход AppBar нь surfaceTint өнгөөр өнгөрсөн
        // tint авдаг — энэ нь bgBase-тай ялгаатай харагдана. Бид tint-ийг
        // унтрааж, scrolledUnderElevation-ыг 0 болгож scroll-ын явцад
        // background bgBase-аараа үлдэхийг баталгаажуулна.
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          // Login дэлгэцтэй ижил pill switcher (flag + MN/ENG).
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: LanguageSwitcher()),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            ProfileHeader(
              name: _userName.isNotEmpty ? _userName : 'Хэрэглэгч',
              phoneNumber: _userPhone,
            ),
            const SizedBox(height: 32),

            // Personal Information Section
            const ProfileSectionHeader(title: 'ХУВИЙН МЭДЭЭЛЭЛ'),
            ProfileToggleItem(
              icon: Icons.dark_mode_outlined,
              title: l10n.darkMode,
              value: theme.brightness == Brightness.dark,
              onChanged: (val) {
                AppStateManager.instance.toggleTheme(val);
              },
            ),
            ProfileListItem(
              icon: Icons.person_outline,
              title: l10n.myInfo,
              subtitle: l10n.myInfoSubtitle,
              onTap: () => Navigator.pushNamed(context, '/my_info'),
              trailing: Icon(
                Icons.info_outline,
                color: extendedColors.yellow,
                size: 20,
              ),
            ),
            ProfileListItem(
              icon: Icons.account_balance_outlined,
              title: l10n.incomeAccount,
              subtitle: l10n.incomeAccountSubtitle,
              onTap: () => Navigator.pushNamed(context, '/income_account'),
            ),
            ProfileListItem(
              icon: Icons.description_outlined,
              title: l10n.summaryReport,
              subtitle: l10n.summaryReportSubtitle,
              onTap: () => Navigator.pushNamed(context, '/summary_report'),
            ),

            // Child Account Section
            const SizedBox(height: 24),
            ProfileSectionHeader(title: l10n.childAccount),
            ProfileListItem(
              icon: Icons.add,
              title: l10n.createNewAccount,
              subtitle: l10n.createNewAccountSubtitle,
              onTap: () {},
            ),

            // Security Section
            const SizedBox(height: 24),
            ProfileSectionHeader(title: l10n.security),
            ProfileToggleItem(
              icon: Icons.fingerprint,
              title: l10n.biometric,
              subtitle: biometricEnabled ? l10n.active : l10n.inactive,
              value: biometricEnabled,
              onChanged: _handleBiometricToggle,
            ),
            ProfileListItem(
              icon: Icons.lock_outline,
              title: l10n.changePassword,
              subtitle: _passDate != null
                  ? l10n.passwordChangedOn(_passDate!)
                  : null,
              onTap: () =>
                  Navigator.pushNamed(context, '/change_password_verify'),
            ),
            ProfileListItem(
              icon: Icons.devices_outlined,
              title: l10n.connectedDevices,
              subtitle: _deviceCount != null
                  ? l10n.deviceCountLabel(_deviceCount!)
                  : null,
              onTap: () => Navigator.pushNamed(context, '/connected_devices'),
            ),

            const SizedBox(height: 40),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: CustomButton(
                  label: l10n.logout,
                  onPressed: () async {
                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LogoutBottomSheet(),
                    );

                    if (result == true && context.mounted) {
                      // Clear authentication session
                      await context.read<AuthService>().clearSession();
                      // Navigate to login and clear stack
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    }
                  },
                  variant: CustomButtonVariant.tertiary,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
