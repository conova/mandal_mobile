import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import 'components/shared/auth_channel_selector.dart';

class ForgotPasswordVerificationScreen extends StatelessWidget {
  const ForgotPasswordVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final channels =
        (args?['channels'] as List<Map<String, dynamic>>?) ?? [];

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: const AuthStepAppBar(stepText: '1/2'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.selectVerifyChannel,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.verifyChannelPrompt,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral200,
              ),
            ),
            const SizedBox(height: 48),
            ...channels.map((channel) {
              final type = channel['type'] as String? ?? '';
              final value = channel['value'] as String? ?? '';
              final isSms = type == 'phone' || type == 'sms';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AuthChannelSelector(
                  icon: isSms
                      ? 'phone'
                      : 'email',
                  title: isSms ? l10n.sms : l10n.emailLabel,
                  value: _maskValue(type, value),
                  onTap: () async {
                    final sessionId = args?['sessionId'] as String?;
                    // Сонгосон сувгаар OTP илгээх (sms эсвэл email)
                    if (sessionId != null) {
                      try {
                        await context.read<AuthService>().sendOtp(
                              isSms ? 'sms' : 'email',
                              sessionId: sessionId,
                            );
                      } catch (e) {
                        if (context.mounted) {
                          CustomSnackbar.show(
                            context,
                            message:
                                e.toString().replaceFirst('Exception: ', ''),
                            type: CustomSnackbarType.error,
                          );
                        }
                        return;
                      }
                    }
                    if (!context.mounted) return;
                    Navigator.pushNamed(
                      context,
                      '/forgot_password_otp',
                      arguments: {
                        'channel': isSms ? l10n.sms : l10n.emailLabel,
                        'value': _maskValue(type, value),
                        'channelType': type,
                        'channelValue': value,
                        'regNo': args?['regNo'],
                        'phone': args?['phone'],
                        'sessionId': sessionId,
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _maskValue(String type, String value) {
    if (value.length <= 4) return value;
    if (type == 'phone' || type == 'sms') {
      return '${value.substring(0, 2)}****${value.substring(value.length - 2)}';
    }
    final atIndex = value.indexOf('@');
    if (atIndex > 2) {
      return '${value.substring(0, 2)}${'*' * (atIndex - 2)}${value.substring(atIndex)}';
    }
    return value;
  }
}
