import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/auth/auth_footer.dart';
import '../../../services/auth_service.dart';
import '../../../common/validators.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (_tabController.index == 1 && email.isEmpty) return;
    if (password.isEmpty) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final userName = _tabController.index == 0
          ? _phoneController.text
          : _emailController.text;

      final result = await authService.login(userName, password);

      if (!mounted) return;

      if (result.success) {
        // DeviceId бүртгэлтэй → шууд нэвтэрсэн
        Navigator.pushReplacementNamed(context, '/main');
      } else if (result.requiresOtp) {
        // DeviceId бүртгэлгүй → "Шинэ төхөөрөмж" introductory screen-ээр
        // оруулаад, тэндээс OTP суваг сонгох flow руу үргэлжилнэ.
        // `pushNamed` (pushReplacement биш) — Буцах товч /login руу
        // ажиллахын тулд login screen-ийг back stack-д үлдээнэ.
        Navigator.pushNamed(
          context,
          '/new_device',
          arguments: {'sessionId': result.sessionId},
        );
      } else {
        // Алдаа (буруу нууц үг гэх мэт) — alert dialog-оор мессежийг харуулна

        final message = result.message ?? l10n.loginErrorPhone;
        final remaining = (result.counter != null && result.attempt != null)
            ? result.attempt! - result.counter!
            : null;
        await _showLoginErrorDialog(
          message: message,
          remaining: remaining,
          isMail: _tabController.index == 1,
        );
      }
    } catch (e) {
      if (mounted) {
        await _showLoginErrorDialog(message: l10n.connectionError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Нэвтрэлтийн алдааны dialog — мессеж + үлдсэн оролдлогын тоо
  Future<void> _showLoginErrorDialog({
    required String message,
    bool? isMail,
    int? remaining,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    isMail ??= false;
    final text = remaining != null
        ? isMail
              ? l10n.attemptsRemainingEmail(remaining < 0 ? 0 : remaining)
              : l10n.attemptsRemaining(remaining < 0 ? 0 : remaining)
        : message;
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            Divider(
              height: 0.5,
              thickness: 1,
              color: extendedColors.neutral500,
            ),
            InkWell(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text(
                  l10n.tryAgain,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: extendedColors.neutral500,
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: extendedColors.primaryMain,
              unselectedLabelColor: extendedColors.neutral200,
              indicatorColor: extendedColors.primaryMain,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              dividerColor: Colors.transparent,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.only(right: 24),
              tabs: [
                Tab(text: l10n.phoneNumber),
                Tab(text: l10n.email),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPhoneForm(l10n, theme, extendedColors),
              _buildEmailForm(l10n, theme, extendedColors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm(AppLocalizations l10n, ThemeData theme, ExtendedColors extendedColors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInput(
            label: l10n.phoneNumber,
            validator: (v) => Validators.validateMongolianPhone(v, l10n),
            keyboardType: TextInputType.phone,
            controller: _phoneController,
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: l10n.password,
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
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: extendedColors.primaryMain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          CustomButton(
            label: l10n.login,
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 24),
          AuthFooter(
            questionText: l10n.newToApp,
            actionText: l10n.register,
            onAction: () => Navigator.pushNamed(context, '/register'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm(AppLocalizations l10n, ThemeData theme, ExtendedColors extendedColors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInput(
            label: l10n.email,
            hint: l10n.emailHint,
            validator: (v) => Validators.validateEmail(v, l10n),
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: l10n.password,
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
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: extendedColors.primaryMain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          CustomButton(
            label: l10n.login,
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 24),
          AuthFooter(
            questionText: l10n.newToApp,
            actionText: l10n.register,
            onAction: () => Navigator.pushNamed(context, '/register'),
          ),
        ],
      ),
    );
  }
}
