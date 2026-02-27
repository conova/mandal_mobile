import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_app_bar.dart';
import '../widgets/auth/auth_footer.dart';
import 'components/register/register_form.dart';
import 'components/register/register_contact_info.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();

  @override
  void dispose() {
    _regNoController.dispose();
    _phoneController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    // Navigate to OTP verification
    Navigator.pushNamed(
      context,
      '/register_otp',
      arguments: {'phone': _phoneController.text},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AuthAppBar(showLogo: true, onClose: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.registerTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.registerSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(height: 48),
            RegisterForm(
              onRegister: _handleRegister,
              regNoController: _regNoController,
              phoneController: _phoneController,
              lastNameController: _lastNameController,
              firstNameController: _firstNameController,
            ),
            const SizedBox(height: 24),
            const RegisterContactInfo(),
            const SizedBox(height: 48),
            AuthFooter(
              questionText: 'Нэвтрэх хаяг байгаа?',
              actionText: 'Нэвтрэх',
              onAction: () => Navigator.pop(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
