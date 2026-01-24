import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ChangePasswordVerifyScreen extends StatelessWidget {
  const ChangePasswordVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '1/2',
                style: TextStyle(
                  color: theme.disabledColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.selectVerifyChannel,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
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
              onTap: () => Navigator.pushNamed(context, '/change_password_code', arguments: {'channel': l10n.sms, 'value': '99****94'}),
            ),
            const SizedBox(height: 16),
            _buildChannelItem(
              context,
              icon: Icons.email_outlined,
              title: l10n.emailLabel,
              value: 'U********r@gmail.com',
              onTap: () => Navigator.pushNamed(context, '/change_password_code', arguments: {'channel': l10n.emailLabel, 'value': 'U********r@gmail.com'}),
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
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
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
                    style: TextStyle(color: theme.disabledColor, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
