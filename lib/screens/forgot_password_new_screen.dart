import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import 'components/shared/auth_password_form.dart';

class ForgotPasswordNewScreen extends StatelessWidget {
  const ForgotPasswordNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final sessionId = args['sessionId'] as String?;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
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
                color: extendedColors.neutral100,
              ),
            ),
            const SizedBox(height: 28),
            AuthPasswordForm(
              onContinue: (password) async {
                if (sessionId == null) {
                  CustomSnackbar.show(
                    context,
                    message: 'Session ID олдсонгүй. Дахин эхэлнэ үү.',
                    type: CustomSnackbarType.error,
                  );
                  return;
                }
                try {
                  await context.read<AuthService>().resetPassword(
                        sessionId: sessionId,
                        password: password,
                        confirmPassword: password,
                      );
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    CustomSnackbar.show(
                      context,
                      message: e.toString().replaceFirst('Exception: ', ''),
                      type: CustomSnackbarType.error,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
