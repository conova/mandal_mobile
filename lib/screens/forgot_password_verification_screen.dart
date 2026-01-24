import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_step_app_bar.dart';

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
            _buildChannelItem(
              context,
              icon: Icons.smartphone_outlined,
              title: l10n.sms,
              value: '99****94',
              onTap: () => Navigator.pushNamed(context, '/forgot_password_otp', arguments: {
                'channel': l10n.sms,
                'value': '99****94',
              }),
            ),
            const SizedBox(height: 16),
            _buildChannelItem(
              context,
              icon: Icons.email_outlined,
              title: l10n.emailLabel,
              value: 'U********r@gmail.com',
              onTap: () => Navigator.pushNamed(context, '/forgot_password_otp', arguments: {
                'channel': l10n.emailLabel,
                'value': 'U********r@gmail.com',
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.brightness == Brightness.dark 
                ? colorScheme.outline.withOpacity(0.2) 
                : Colors.grey[200]!
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark 
                    ? colorScheme.surfaceVariant 
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.onSurface),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: theme.disabledColor, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }
}
