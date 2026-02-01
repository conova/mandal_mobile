import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import 'components/shared/auth_channel_selector.dart';

class ForgotPasswordVerificationScreen extends StatelessWidget {
  const ForgotPasswordVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              l10n.selectVerifyChannel,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.verifyChannelPrompt,
              style: TextStyle(color: theme.disabledColor, fontSize: 16),
            ),
            const SizedBox(height: 48),
            AuthChannelSelector(
              icon: Icons.smartphone_outlined,
              title: l10n.sms,
              value: '99****94',
              onTap: () => Navigator.pushNamed(
                context,
                '/forgot_password_otp',
                arguments: {'channel': l10n.sms, 'value': '99****94'},
              ),
            ),
            const SizedBox(height: 16),
            AuthChannelSelector(
              icon: Icons.email_outlined,
              title: l10n.emailLabel,
              value: 'U********r@gmail.com',
              onTap: () => Navigator.pushNamed(
                context,
                '/forgot_password_otp',
                arguments: {
                  'channel': l10n.emailLabel,
                  'value': 'U********r@gmail.com',
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
