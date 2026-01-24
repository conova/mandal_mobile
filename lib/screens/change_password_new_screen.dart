import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_snackbar.dart';

import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../widgets/custom_input.dart';

class ChangePasswordNewScreen extends StatefulWidget {
  const ChangePasswordNewScreen({super.key});

  @override
  State<ChangePasswordNewScreen> createState() => _ChangePasswordNewScreenState();
}

class _ChangePasswordNewScreenState extends State<ChangePasswordNewScreen> {
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
        ApiConfig.refreshToken, // Using refresh token endpoint as dummy for password change
        data: {'password': _passController.text},
      );
      if (mounted) {
        CustomSnackbar.show(context, message: 'Password changed successfully');
        Navigator.popUntil(context, ModalRoute.withName('/profile'));
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, message: 'Failed to change password: ${e.toString()}');
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
                '2/2',
                style: TextStyle(
                  color: theme.disabledColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.createNewPassword,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
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
            _buildValidationRule(l10n.atLeast8Chars, _has8Chars),
            _buildValidationRule(l10n.uppercaseLetter, _hasUpper),
            _buildValidationRule(l10n.lowercaseLetter, _hasLower),
            _buildValidationRule(l10n.numberDigit, _hasNumber),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_has8Chars && _hasUpper && _hasLower && _hasNumber && _passController.text == _repeatController.text && !_isLoading)
                    ? _handleSubmitPassword
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceVariant,
                  foregroundColor: colorScheme.onSurface,
                  disabledBackgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        l10n.continueLabel,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildValidationRule(String label, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 20,
            color: isValid ? Colors.teal[400] : Colors.grey[300],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isValid ? Colors.black87 : Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
