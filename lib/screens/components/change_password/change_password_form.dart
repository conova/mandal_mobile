import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_input.dart';
import '../../../../services/api_service.dart';
import '../../../../config/api_config.dart';
import '../../../../widgets/custom_snackbar.dart';
import '../shared/password_validation_rules.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repeatController = TextEditingController();
  bool _isLoading = false;

  bool _has8Chars = false;
  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final pass = _passController.text;
    setState(() {
      _has8Chars = pass.length >= 8;
      _hasUpper = pass.contains(RegExp(r'[A-Z]'));
      _hasLower = pass.contains(RegExp(r'[a-z]'));
      _hasNumber = pass.contains(RegExp(r'[0-9]'));
    });
  }

  Future<void> _handleSubmitPassword() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      await apiService.post(
        ApiConfig.refreshToken,
        data: {'password': _passController.text},
      );
      if (mounted) {
        CustomSnackbar.show(context, message: 'Password changed successfully');
        Navigator.popUntil(context, ModalRoute.withName('/profile'));
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Failed to change password: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isValid =
        _has8Chars &&
        _hasUpper &&
        _hasLower &&
        _hasNumber &&
        _passController.text == _repeatController.text;

    return Column(
      children: [
        CustomInput(
          label: l10n.passwordHint,
          controller: _passController,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: l10n.repeatPasswordHint,
          controller: _repeatController,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        PasswordValidationRules(
          has8Chars: _has8Chars,
          hasUpper: _hasUpper,
          hasLower: _hasLower,
          hasNumber: _hasNumber,
          label8Chars: l10n.atLeast8Chars,
          labelUpper: l10n.uppercaseLetter,
          labelLower: l10n.lowercaseLetter,
          labelNumber: l10n.numberDigit,
        ),
        const SizedBox(height: 64),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (isValid && !_isLoading) ? _handleSubmitPassword : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surfaceVariant,
              foregroundColor: colorScheme.onSurface,
              disabledBackgroundColor: colorScheme.surfaceVariant.withOpacity(
                0.3,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.continueLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
