import 'package:flutter/material.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import 'components/shared/auth_channel_selection_form.dart';

class LoginVerificationScreen extends StatelessWidget {
  const LoginVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final sessionId = args?['sessionId'] as String?;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AuthStepAppBar(stepText: '1/2'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AuthChannelSelectionForm(
          nextRoute: '/login_otp',
          extraArgs: {'sessionId': sessionId},
        ),
      ),
    );
  }
}
