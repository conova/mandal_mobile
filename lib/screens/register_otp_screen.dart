import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import 'components/shared/auth_otp_form.dart';

class RegisterOtpScreen extends StatelessWidget {
  const RegisterOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final phone = args['phone'] as String;
    final sessionId = args['sessionId'] as String?;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '1/4'),
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
              l10n.codeSentTo(phone),
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
                '/register_password',
                arguments: args,
              ),
              onResend: () async {
                if (sessionId == null) return;
                try {
                  final auth = context.read<AuthService>();
                  final data = await auth.sendOtp(sessionId, 'sms');
                  // TEST: дахин илгээсэн OTP-г харуулах
                  final otp = data['otp']?.toString();
                  if (otp != null && context.mounted) {
                    CustomSnackbar.show(
                      context,
                      message: 'OTP код: $otp',
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
