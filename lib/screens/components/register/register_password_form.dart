import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_input.dart';
import '../../../../widgets/custom_button.dart';
import '../shared/password_validation_rules.dart';

class RegisterPasswordForm extends StatefulWidget {
  final VoidCallback onContinue;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegisterPasswordForm({
    super.key,
    required this.onContinue,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<RegisterPasswordForm> createState() => _RegisterPasswordFormState();
}

class _RegisterPasswordFormState extends State<RegisterPasswordForm> {
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_validatePassword);
    widget.confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_validatePassword);
    widget.confirmPasswordController.removeListener(_validatePassword);
    super.dispose();
  }

  void _validatePassword() {
    final password = widget.passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));

      _isButtonEnabled =
          _hasMinLength &&
          _hasUppercase &&
          _hasLowercase &&
          _hasNumber &&
          password == widget.confirmPasswordController.text &&
          password.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CustomInput(
          label: l10n.password,
          hint: '',
          isPassword: true,
          controller: widget.passwordController,
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: l10n.repeatPasswordHint,
          hint: '',
          isPassword: true,
          controller: widget.confirmPasswordController,
        ),
        const SizedBox(height: 24),
        PasswordValidationRules(
          has8Chars: _hasMinLength,
          hasUpper: _hasUppercase,
          hasLower: _hasLowercase,
          hasNumber: _hasNumber,
          label8Chars: l10n.atLeast8Chars,
          labelUpper: l10n.uppercaseLetter,
          labelLower: l10n.lowercaseLetter,
          labelNumber: l10n.numberDigit,
        ),
        const SizedBox(height: 48), // Spacer replacement
        CustomButton(
          label: l10n.continueBtn,
          onPressed: _isButtonEnabled ? widget.onContinue : null,
          variant: CustomButtonVariant.primary,
        ),
      ],
    );
  }
}
