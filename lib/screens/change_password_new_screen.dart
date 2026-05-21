import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import 'components/shared/auth_password_form.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';

class ChangePasswordNewScreen extends StatelessWidget {
  const ChangePasswordNewScreen({super.key});

  Future<void> _handleSubmitPassword(
    BuildContext context,
    String password,
  ) async {
    try {
      final authService = context.read<AuthService>();
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final sessionId = args?['sessionId'] as String?;

      if (sessionId == null || sessionId.isEmpty) {
        throw Exception('Session ID байхгүй байна');
      }

      // OTP-аар хэрэглэгчийг баталгаажуулсан тул resetPassword-аар шинэ нууц
      // үг тавьна (change_password биш, register/reset endpoint).
      await authService.resetPassword(
        sessionId: sessionId,
        password: password,
        confirmPassword: password,
      );

      if (context.mounted) {
        CustomSnackbar.show(context, message: 'Нууц үг амжилттай солигдлоо');
        Navigator.popUntil(context, ModalRoute.withName('/profile'));
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: 'Алдаа: ${e.toString().replaceFirst('Exception: ', '')}',
          type: CustomSnackbarType.error,
        );
        rethrow;
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
      appBar: const AuthStepAppBar(stepText: '2/2'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.createNewPassword,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            AuthPasswordForm(
              onContinue: (password) =>
                  _handleSubmitPassword(context, password),
              continueLabel: l10n.continueLabel,
            ),
          ],
        ),
      ),
    );
  }
}
