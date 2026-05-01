import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_state_manager.dart';
import '../widgets/custom_button.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Toggle language mn/en
              final current = AppStateManager.instance.locale.languageCode;
              AppStateManager.instance.setLocale(
                Locale(current == 'mn' ? 'en' : 'mn'),
              );
            },
            icon: CircleAvatar(
              radius: 10,
              backgroundColor: colorScheme.surfaceVariant,
              child: Text(
                AppStateManager.instance.locale.languageCode == 'mn'
                    ? 'MN'
                    : 'EN',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            label: Text(
              AppStateManager.instance.locale.languageCode == 'mn'
                  ? 'MNG'
                  : 'ENG',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
              subtitle: l10n.inactive,
              value: false,
              onChanged: (val) {},
            ),
            ProfileListItem(
              icon: Icons.lock_outline,
              title: l10n.changePassword,
              subtitle: l10n.lastChanged,
              onTap: () =>
                  Navigator.pushNamed(context, '/change_password_verify'),
            ),
            ProfileListItem(
              icon: Icons.devices_outlined,
              title: l10n.connectedDevices,
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
