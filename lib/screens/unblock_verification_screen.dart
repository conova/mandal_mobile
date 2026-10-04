import 'package:flutter/material.dart';
import '../theme/extended_colors.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import 'components/shared/auth_channel_selection_form.dart';

/// Блок гаргах — OTP суваг сонгох (BlockedScreen-ээс sessionId-тай ирнэ).
/// Дараагийн алхам нь нууц үг сэргээх OTP screen (flow: 'unblock' → /login).
class UnblockVerificationScreen extends StatelessWidget {
  const UnblockVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: const AuthStepAppBar(stepText: '1/2'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AuthChannelSelectionForm(
          nextRoute: '/forgot_password_otp',
          extraArgs: {'sessionId': args?['sessionId'], 'flow': 'unblock'},
        ),
      ),
    );
  }
}
