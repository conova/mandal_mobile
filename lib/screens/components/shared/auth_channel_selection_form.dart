import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'auth_channel_selector.dart';

class AuthChannelSelectionForm extends StatelessWidget {
  final String nextRoute;

  const AuthChannelSelectionForm({super.key, required this.nextRoute});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          l10n.selectVerifyChannel,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.verifyChannelPrompt,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 48),
        AuthChannelSelector(
          icon: Icons.smartphone_outlined,
          title: l10n.sms,
          value: '99****94',
          onTap: () => Navigator.pushNamed(
            context,
            nextRoute,
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
            nextRoute,
            arguments: {
              'channel': l10n.emailLabel,
              'value': 'U********r@gmail.com',
            },
          ),
        ),
      ],
    );
  }
}
