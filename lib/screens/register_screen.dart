import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/auth/auth_app_bar.dart';
import '../widgets/auth/auth_footer.dart';
import '../widgets/custom_snackbar.dart';
import '../services/auth_service.dart';
import 'components/register/register_form.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _regNoController.dispose();
    _phoneController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    final regNo = _regNoController.text.trim();
    final phone = _phoneController.text.trim();
    final lastName = _lastNameController.text.trim();
    final firstName = _firstNameController.text.trim();

    if (regNo.isEmpty ||
        phone.isEmpty ||
        lastName.isEmpty ||
        firstName.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final data = await authService.registerInitiate(
        registerNumber: regNo,
        phone: phone,
        lastName: lastName,
        firstName: firstName,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final sessionId = data['sessionId']?.toString();
      final custId = data['custId']?.toString();

      // TEST: OTP код харуулах (бодит сервер илгээхгүй болгоно)
      final otp = data['otp']?.toString();
      if (otp != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('OTP код: $otp')));
      }

      Navigator.pushNamed(
        context,
        '/register_otp',
        arguments: {
          'phone': phone,
          'regNo': regNo,
          'lastName': lastName,
          'firstName': firstName,
          'sessionId': sessionId,
          'custId': custId,
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AuthAppBar(showLogo: true, onClose: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.registerTitle,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.registerSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral200,
              ),
            ),
            const SizedBox(height: 48),
            RegisterForm(
              onRegister: _handleRegister,
              regNoController: _regNoController,
              phoneController: _phoneController,
              lastNameController: _lastNameController,
              firstNameController: _firstNameController,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 28),
            AuthFooter(
              questionText: l10n.alreadyHaveAccount,
              actionText: l10n.login,
              onAction: () => Navigator.pop(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
