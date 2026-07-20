import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';
import '../widgets/language_switcher.dart';
import '../widgets/auth/biometric_login_button.dart';
import '../services/auth_service.dart';

class QuickLoginScreen extends StatefulWidget {
  const QuickLoginScreen({super.key});

  @override
  State<QuickLoginScreen> createState() => _QuickLoginScreenState();
}

class _QuickLoginScreenState extends State<QuickLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Нууц үгээр нэвтрэх
  Future<void> _handleLogin() async {
    final password = _passwordController.text;
    if (password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final userName = authService.savedUser['id'] ?? '';

      final result = await authService.login(userName, password);

      if (!mounted) return;

      if (result.success) {
        Navigator.pushReplacementNamed(context, '/main');
      } else if (result.requiresOtp) {
        Navigator.pushReplacementNamed(
          context,
          '/login_verification',
          arguments: {'sessionId': result.sessionId},
        );
      } else {
        CustomSnackbar.show(
          context,
          message: result.message ?? 'Login failed',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Биометрик нэвтрэлт — товч өөрөө биометрикийг шалгаж дуудсан учир
  /// энд зөвхөн серверийн API-г дуудна.
  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final result = await authService.biometricLogin();

      if (!mounted) return;

      if (result.success) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        CustomSnackbar.show(
          context,
          message: result.message ?? 'Biometric login failed',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();
    final extendedColors = theme.extension<ExtendedColors>()!;
    final savedUser = authService.savedUser;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await authService.clearSession();
                      await authService.clearLastUser();
                      if (mounted) {
                        nav.pushReplacementNamed('/login');
                      }
                    },
                    icon: CustomSvgIcon('close-button'),
                    label: Text(
                      l10n.useAnotherAccount,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100,
                        fontWeight: AppTextStyles.regular,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: Size(171, 40),
                      backgroundColor: extendedColors.bgSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const LanguageSwitcher(),
                ],
              ),
              const Spacer(flex: 3),

              // User Profile Section
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, top: 20, right: 10),
                  child: CustomSvgIcon('user', size: 20, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24,),
              Text(
                savedUser['name'] ?? 'Мандал хэрэглэгч',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: extendedColors.neutral100,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                savedUser['id'] ?? '',
                style: AppTextStyles.body2.copyWith(color: theme.disabledColor),
              ),
              const SizedBox(height: 32),

              // Input Section
              CustomInput(
                label: l10n.password,
                hint: l10n.password,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/forgot_password'),
                  child: Text(
                    l10n.forgotPasswordBtn,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppTextStyles.regular,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1,),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: l10n.login,
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (authService.isBiometricEnabled)
                    BiometricLoginButton(
                      onAuthenticated: _handleBiometricLogin,
                      onError: () {
                        CustomSnackbar.show(
                          context,
                          message: 'Биометрик баталгаажуулалт амжилтгүй',
                          type: CustomSnackbarType.error,
                        );
                      },
                    ),
                ],
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
