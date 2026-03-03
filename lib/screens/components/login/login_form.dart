import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input.dart';
import '../../../widgets/auth/auth_footer.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_snackbar.dart';
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
    // Basic validation
    final email = _emailController.text;
    final password = _passwordController.text;

    // Note: In the original code, it checks both but they are in separate forms.
    // We'll just check if the relevant field for the current tab is filled.
    if (_tabController.index == 1 && email.isEmpty) return;
    if (password.isEmpty) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final userName = _tabController.index == 0
          ? _phoneController.text
          : _emailController.text;

      // Mocking tokens as in original code
      await authService.saveTokens(accessToken: "123", refreshToken: "312312");

      // await authService.login(userName, password);

      // Save user info for Quick Login
      await authService.saveLastUser('Өлзийдэлгэр', userName);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login_verification');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: _tabController.index == 1
              ? l10n.loginErrorEmail
              : l10n.loginErrorPhone,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
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
              _buildPhoneForm(l10n, theme),
              _buildEmailForm(l10n, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInput(
            label: l10n.phoneNumber,
            hint: '99101294',
            keyboardType: TextInputType.phone,
            controller: _phoneController,
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: l10n.password,
            hint: 'Qwerty123#',
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
                  color: theme.colorScheme.primary,
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

  Widget _buildEmailForm(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInput(
            label: l10n.email,
            hint: l10n.emailHint,
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: l10n.password,
            hint: '********',
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
                  color: theme.colorScheme.primary,
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
