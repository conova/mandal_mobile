import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../services/auth_service.dart';
import 'components/forgot_password/forgot_password_form.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _regNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    final regNo = _regNoController.text.trim();
    final phone = _phoneController.text.trim();

    if (regNo.isEmpty || phone.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final data = await authService.forgotPassword(
        registerNumber: regNo,
        phone: phone,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        final channels = (data['channels'] as List? ?? [])
            .map((c) => Map<String, dynamic>.from(c as Map))
            .toList();
        // TEST: дамжуулсан OTP
        final otp = data['otp']?.toString();
        if (otp != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP код: $otp')),
          );
        }
        Navigator.pushNamed(
          context,
          '/forgot_password_verification',
          arguments: {
            'channels': channels,
            'regNo': regNo,
            'phone': phone,
            'sessionId': data['sessionId']?.toString(),
          },
        );
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
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.forgotPasswordTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.forgotPasswordSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: extendedColors.neutral500,
              ),
            ),
            const SizedBox(height: 48),
            ForgotPasswordForm(
              onContinue: _handleContinue,
              regNoController: _regNoController,
              phoneController: _phoneController,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
