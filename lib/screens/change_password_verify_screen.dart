import 'package:flutter/material.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import 'components/shared/auth_channel_selection_form.dart';

class ChangePasswordVerifyScreen extends StatelessWidget {
  const ChangePasswordVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '1/2'),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: AuthChannelSelectionForm(nextRoute: '/change_password_code'),
      ),
    );
  }
}
