import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
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

  Future<void> _handleLogin() async {
    // Implementation for login logic
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    if (mounted) {
      setState(() => _isLoading = false);
      // Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authService = context.watch<AuthService>();
    final savedUser = authService.savedUser;

    return Scaffold(
      backgroundColor: colorScheme.background,
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
                      await authService.clearSession();
                      await authService.clearLastUser();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: Text(
                      l10n.useAnotherAccount,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.neutral100,
                        fontWeight: AppTextStyles.regular,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.bgSecondary,
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
              const Spacer(flex: 2),

              // User Profile Section
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 64, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Text(
                savedUser['name'] ?? 'Мандал хэрэглэгч',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                savedUser['id'] ?? '',
                style: AppTextStyles.body2.copyWith(color: theme.disabledColor),
              ),
              const Spacer(flex: 1),

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
              const Spacer(flex: 3),

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
                      onAuthenticated: _handleLogin,
                      onError: () {
                        // Optional error handling
                      },
                    ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
