import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import 'components/shared/auth_otp_form.dart';

class ForgotPasswordOtpScreen extends StatelessWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final value = args['value'] as String;
    final sessionId = args['sessionId'] as String?;
    final channelType = args['channelType'] as String?;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '1/2'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.enterCodeTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            Text(
              l10n.codeSentTo(value),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            AuthOtpForm(
              sessionId: sessionId,
              onSuccess: () => Navigator.pushNamed(
                context,
                '/forgot_password_new',
                arguments: args,
              ),
              onResend: () async {
                if (sessionId == null || channelType == null) return;
                try {
                  await context.read<AuthService>().sendOtp(
                        sessionId,
                        channelType == 'phone' ? 'sms' : channelType,
                      );
                  if (context.mounted) {
                    CustomSnackbar.show(
                      context,
                      message: 'Кодыг дахин илгээлээ',
                      type: CustomSnackbarType.info,
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
          ],
        ),
      ),
    );
  }
}
