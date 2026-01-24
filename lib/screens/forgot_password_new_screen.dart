import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../theme/extended_colors.dart';

class ForgotPasswordNewScreen extends StatefulWidget {
  const ForgotPasswordNewScreen({super.key});

  @override
  State<ForgotPasswordNewScreen> createState() => _ForgotPasswordNewScreenState();
}

class _ForgotPasswordNewScreenState extends State<ForgotPasswordNewScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _isButtonEnabled = false;

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
      
      _isButtonEnabled = _hasMinLength && 
                        _hasUppercase && 
                        _hasLowercase && 
                        _hasNumber &&
                        password == _confirmPasswordController.text &&
                        password.isNotEmpty;
    });
  }

  void _handleContinue() {
    if (!_isButtonEnabled) return;
    // Navigate to success or main screen
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '2/2',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
              l10n.createNewPassword,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 48),
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
            _buildRequirement(l10n.atLeast8Chars, _hasMinLength, colorScheme, extendedColors),
            const SizedBox(height: 8),
            _buildRequirement(l10n.uppercaseLetter, _hasUppercase, colorScheme, extendedColors),
            const SizedBox(height: 8),
            _buildRequirement(l10n.lowercaseLetter, _hasLowercase, colorScheme, extendedColors),
            const SizedBox(height: 8),
            _buildRequirement(l10n.numberDigit, _hasNumber, colorScheme, extendedColors),
            const Spacer(),
            CustomButton(
              label: l10n.continueBtn,
              onPressed: _isButtonEnabled ? _handleContinue : null,
              variant: CustomButtonVariant.primary,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet, ColorScheme colorScheme, ExtendedColors extendedColors) {
    return Row(
      children: [
        Icon(
          Icons.check,
          size: 20,
          color: isMet ? colorScheme.primary : extendedColors.neutral300,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isMet ? colorScheme.primary : extendedColors.neutral300,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
