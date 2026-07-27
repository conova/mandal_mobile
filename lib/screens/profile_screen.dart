import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_state_manager.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/initial_avatar.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';
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
  String? _photoUrl; // Харилцагчийн зургийн URL (null бол default icon)
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
    // Хүүхдийн профайл идэвхтэй үед өөрийн info-г дуудах шаардлагагүй —
    // header хүүхдийн мэдээллээ subAcnts-аас авдаг
    if (context.read<AuthService>().activeSubAccount != null) return;
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(ApiConfig.userInfo);
      final body = response.data;

      if (mounted && body['code']?.toString() == '0' && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        setState(() {
          _userName = data['firstName']?.toString() ?? '';
          _userPhone = data['phone']?.toString() ?? '';
          _photoUrl = data['photo']?.toString();
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
    final extendedColors = theme.extension<ExtendedColors>()!;
    final biometricEnabled = context.watch<AuthService>().isBiometricEnabled;

    // Home дээр хүүхдийн данс руу сольсон бол profile хязгаарлагдмал
    // цэстэй (Миний мэдээлэл, Орлого авах данс, Хураангуй тайлан)
    final activeChild = context.watch<AuthService>().activeSubAccount;
    final isChildProfile = activeChild != null;
    final lang = Localizations.localeOf(context).languageCode;

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
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
        actions: const [
          // Login дэлгэцтэй ижил pill switcher (flag + MN/ENG).
          Padding(
            padding: EdgeInsets.only(right: 16, top: 10),
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
              name: isChildProfile
                  ? activeChild.nameOf(lang)
                  : (_userName.isNotEmpty ? _userName : 'Хэрэглэгч'),
              phoneNumber: isChildProfile ? activeChild.phone : _userPhone,
              photoUrl: isChildProfile ? null : _photoUrl,
              avatar: isChildProfile
                  ? InitialAvatar(
                      initial: activeChild.initial,
                      color: extendedColors.purple,
                      size: 90,
                    )
                  : null,
            ),
            const SizedBox(height: 32),

            // Personal Information Section
            ProfileSectionHeader(title: l10n.personalInfo),
            if (!isChildProfile)
              ProfileToggleItem(
                icon: AppStateManager.instance.themeMode == ThemeMode.dark
                    ? const CustomSvgIcon('sun', size: 20)
                    : const CustomSvgIcon('moon-01', size: 20),
                title: AppStateManager.instance.themeMode != ThemeMode.dark
                    ? l10n.darkMode
                    : l10n.lightMode,
                value: theme.brightness == Brightness.dark,
                onChanged: (val) {
                  AppStateManager.instance.toggleTheme(val);
                },
              ),
            ProfileListItem(
              icon: const CustomSvgIcon('user-03', size: 20),
              title: l10n.myInfo,
              subtitle: l10n.myInfoSubtitle,
              onTap: () => Navigator.pushNamed(
                context,
                '/my_info',
                arguments: isChildProfile ? {'child': activeChild} : null,
              ),
              trailing: isChildProfile
                  ? null
                  : const CustomSvgIcon(
                      'info-circle',
                      size: 20,
                      color: AppColors.yellowMain,
                    ),
            ),
            ProfileListItem(
              icon: const CustomSvgIcon('bank', size: 20),
              title: l10n.incomeAccount,
              subtitle: l10n.incomeAccountSubtitle,
              onTap: () => Navigator.pushNamed(context, '/income_account'),
            ),
            ProfileListItem(
              icon: const CustomSvgIcon('file-05', size: 20),
              title: l10n.summaryReport,
              subtitle: l10n.summaryReportSubtitle,
              onTap: () => Navigator.pushNamed(context, '/summary_report'),
            ),

            // Child Account Section — хүүхдийн профайлд харагдахгүй
            if (!isChildProfile) ...[
              const SizedBox(height: 24),
              ProfileSectionHeader(title: l10n.childAccount),
              // Бүртгэлтэй хүүхдүүд — /user/info-ийн subAcnts
              ...context.watch<AuthService>().subAccounts.map(
                (child) => ProfileListItem(
                  icon: SizedBox(
                    width: 20,
                    height: 20,
                    // Үсгийг хэвтээ/босоо голлуулна
                    child: Center(
                      child: Text(
                        child.initial,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  iconBackgroundColor: extendedColors.primaryMain,
                  title: child.nameOf(
                    Localizations.localeOf(context).languageCode,
                  ),
                  subtitle:
                      '₮${formatStockAmount(child.amount).replaceAll('₮', '')}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/my_info',
                    arguments: {'child': child},
                  ),
                ),
              ),
              ProfileListItem(
                icon: const CustomSvgIcon('plus', size: 20),
                title: l10n.createNewAccount,
                subtitle: l10n.createNewAccountSubtitle,
                onTap: () =>
                    Navigator.pushNamed(context, '/child_account_register'),
              ),

              // Security Section
              const SizedBox(height: 24),
              ProfileSectionHeader(title: l10n.security),
              ProfileToggleItem(
                icon: const CustomSvgIcon('fingerprint-03', size: 20),
                title: l10n.biometric,
                subtitle: biometricEnabled ? l10n.active : l10n.inactive,
                value: biometricEnabled,
                onChanged: _handleBiometricToggle,
              ),
              ProfileListItem(
                icon: const CustomSvgIcon('lock-04', size: 20),
                title: l10n.changePassword,
                subtitle: _passDate != null
                    ? l10n.passwordChangedOn(_passDate!)
                    : null,
                onTap: () =>
                    Navigator.pushNamed(context, '/change_password_verify'),
              ),
              ProfileListItem(
                icon: const CustomSvgIcon('phone-02', size: 20),
                title: l10n.connectedDevices,
                subtitle: _deviceCount != null
                    ? l10n.deviceCountLabel(_deviceCount!)
                    : null,
                onTap: () => Navigator.pushNamed(context, '/connected_devices'),
              ),
            ],

              const SizedBox(height: 40),

              ProfileListItem(
                icon: CustomSvgIcon(
                  'log-out-04',
                  size: 20,
                  color: extendedColors.red,
                ),
                titleColor: extendedColors.red,
                iconColor: extendedColors.red,
                iconBackgroundColor: extendedColors.red100,
                title: l10n.logout,
                onTap: () async {
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
              ),
              const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
