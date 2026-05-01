import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../services/auth_service.dart';
import 'components/shared/auth_otp_form.dart';

class LoginOtpScreen extends StatelessWidget {
  const LoginOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final value = args?['value'] as String? ?? '';
    final sessionId = args?['sessionId'] as String?;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '2/2'),
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
              onSuccess: () async {
                // OTP амжилттай → deviceId бүртгэж token авах
                if (sessionId != null) {
                  final authService = context.read<AuthService>();
                  final nav = Navigator.of(context);
                  final result = await authService.registerDevice(sessionId);

                  if (context.mounted) {
                    if (result.success) {
                      nav.pushReplacementNamed('/main');
                    } else {
                      CustomSnackbar.show(
                        context,
                        message: result.message ?? 'Device registration failed',
                        type: CustomSnackbarType.error,
                      );
                    }
                  }
                } else {
                  Navigator.pushReplacementNamed(context, '/main');
                }
              },
              onResend: () {
                // OTP дахин илгээх
                if (sessionId != null) {
                  final authService = context.read<AuthService>();
                  final channel = args?['channel'] as String? ?? 'sms';
                  final channelType = channel.toLowerCase() == 'email' ? 'email' : 'sms';
                  authService.sendOtp(sessionId, channelType).then((_) {
                    if (context.mounted) {
                      CustomSnackbar.show(context, message: 'OTP код дахин илгээлээ');
                    }
                  }).catchError((e) {
                    if (context.mounted) {
                      CustomSnackbar.show(
                        context,
                        message: 'OTP илгээхэд алдаа: ${e.toString()}',
                        type: CustomSnackbarType.error,
                      );
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
