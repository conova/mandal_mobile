import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_app_bar.dart';
import '../widgets/auth/auth_footer.dart';
import '../widgets/custom_snackbar.dart';
import '../services/auth_service.dart';
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

    if (regNo.isEmpty || phone.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final result = await authService.registerValidate(regNo, phone);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['canRegister'] == true) {
          // 404 → бүртгэлгүй → утас руу OTP илгээх
          final otpData = await authService.sendRegisterOtp(phone);
          final sessionId = otpData['sessionId'] as String?;

          // TEST: OTP код харуулах
          final otp = otpData['otp']?.toString();
          if (otp != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OTP код: $otp')),
            );
          }

          if (mounted) {
            Navigator.pushNamed(
              context,
              '/register_otp',
              arguments: {
                'phone': phone,
                'regNo': regNo,
                'lastName': _lastNameController.text.trim(),
                'firstName': _firstNameController.text.trim(),
                'sessionId': sessionId,
              },
            );
          }
        } else {
          // 200/400 → бүртгэлтэй → анхааруулга
          CustomSnackbar.show(
            context,
            message: result['message'] ?? 'Та бүртгэлтэй байна',
            type: CustomSnackbarType.error,
          );
        }
      }
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
              isLoading: _isLoading,
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
