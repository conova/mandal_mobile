import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/extended_colors.dart';
import 'otp_input_field.dart';

class AuthOtpForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onResend;

  const AuthOtpForm({
    super.key,
    required this.onSuccess,
    required this.onResend,
  });

  @override
  State<AuthOtpForm> createState() => _AuthOtpFormState();
}

class _AuthOtpFormState extends State<AuthOtpForm> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _attemptCount = 0;
  bool _isBlocked = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (_isBlocked) return;

    setState(() {
      _errorMessage = null;
    });

    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all filled
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    if (_isBlocked) return;

    final enteredCode = _controllers.map((c) => c.text).join();

    // Mock validation - correct code is "1234"
    if (enteredCode == "1234") {
      widget.onSuccess();
    } else {
      setState(() {
        _attemptCount++;

        if (_attemptCount >= 5) {
          _isBlocked = true;
          _errorMessage =
              'Таны эрх түр хаагдлаа. 30 минутын дараа дахин оролдоно уу.';
        } else {
          _errorMessage =
              '4 оронтой код буруу байна. Танд ${5 - _attemptCount} удаагийн эрх үлдлээ.';
        }

        // Clear all fields
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            4,
            (index) => Row(
              children: [
                _buildCodeField(index, theme, extendedColors),
                if (index < 3) const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.error,
              fontWeight: AppTextStyles.light,
            ),
          ),
        ],
        const SizedBox(height: 32),
        Row(
          children: [
            Text(
              l10n.noCodeReceived,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: AppTextStyles.extraLight,
              ),
            ),
            TextButton(
              onPressed: widget.onResend,
              child: Text(
                l10n.resendCode,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: AppTextStyles.regular,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCodeField(
    int index,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    return OtpInputField(
      controller: _controllers[index],
      focusNode: _focusNodes[index],
      isError: _errorMessage != null && !_isBlocked,
      enabled: !_isBlocked,
      onChanged: (value) => _onChanged(value, index),
    );
  }
}
