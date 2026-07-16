import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_input.dart';
import '../../../../widgets/custom_button.dart';
import 'password_validation_rules.dart';

class AuthPasswordForm extends StatefulWidget {
  final Future<void> Function(String password) onContinue;
  final String? continueLabel;

  const AuthPasswordForm({
    super.key,
    required this.onContinue,
    this.continueLabel,
  });

  @override
  State<AuthPasswordForm> createState() => _AuthPasswordFormState();
}

class _AuthPasswordFormState extends State<AuthPasswordForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  bool get _isButtonEnabled {
    final password = _passwordController.text;
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        password == _confirmPasswordController.text &&
        password.isNotEmpty;
  }

  Future<void> _handleContinue() async {
    if (!_isButtonEnabled || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onContinue(_passwordController.text);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          controller: _passwordController,
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: l10n.repeatPasswordHint,
          hint: '',
          isPassword: true,
          controller: _confirmPasswordController,
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
        const SizedBox(height: 48),
        CustomButton(
          label: widget.continueLabel ?? l10n.continueBtn,
          onPressed: _isButtonEnabled && !_isLoading ? _handleContinue : null,
          variant: CustomButtonVariant.primary,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
