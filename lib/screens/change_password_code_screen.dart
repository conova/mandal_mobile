import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import 'components/shared/otp_input_fields.dart';

class ChangePasswordCodeScreen extends StatefulWidget {
  const ChangePasswordCodeScreen({super.key});

  @override
  State<ChangePasswordCodeScreen> createState() =>
      _ChangePasswordCodeScreenState();
}

class _ChangePasswordCodeScreenState extends State<ChangePasswordCodeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final channel = args['channel'] as String;
    final value = args['value'] as String;

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
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.codeSentTo(channel, value),
              style: TextStyle(color: theme.disabledColor, fontSize: 16),
            ),
            const SizedBox(height: 48),
            OtpInputFields(
              onCompleted: (code) {
                Navigator.pushNamed(context, '/change_password_new');
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  l10n.noCodeReceived,
                  style: TextStyle(color: theme.disabledColor),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.resendCode,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
