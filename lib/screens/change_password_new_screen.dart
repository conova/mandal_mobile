import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import 'components/shared/auth_password_form.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../widgets/custom_snackbar.dart';

class ChangePasswordNewScreen extends StatelessWidget {
  const ChangePasswordNewScreen({super.key});

  Future<void> _handleSubmitPassword(
    BuildContext context,
    String password,
  ) async {
    try {
      final apiService = context.read<ApiService>();
      await apiService.post(
        ApiConfig
            .refreshToken, // Note: This was the endpoint in ChangePasswordForm
        data: {'password': password},
      );
      if (context.mounted) {
        CustomSnackbar.show(context, message: 'Password changed successfully');
        Navigator.popUntil(context, ModalRoute.withName('/profile'));
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: 'Failed to change password: ${e.toString()}',
        );
        rethrow; // Re-throw to let AuthPasswordForm handle loading state termination
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '2/2'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.createNewPassword,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            AuthPasswordForm(
              onContinue: (password) =>
                  _handleSubmitPassword(context, password),
              continueLabel: l10n.continueLabel,
            ),
          ],
        ),
      ),
    );
  }
}
