import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/extended_colors.dart';
import '../../../../services/auth_service.dart';
import 'otp_input_field.dart';

class AuthOtpForm extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onResend;

  /// OTP шалгахад ашиглах sessionId (null бол mock validation)
  final String? sessionId;

  const AuthOtpForm({
    super.key,
    required this.onSuccess,
    required this.onResend,
    this.sessionId,
  });

  @override
  State<AuthOtpForm> createState() => _AuthOtpFormState();
}

class _AuthOtpFormState extends State<AuthOtpForm> {
  static const int _otpLength = 4;
  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());
  int _attemptCount = 0;
  bool _isBlocked = false;
  bool _isVerifying = false;
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
    if (_isBlocked || _isVerifying) return;

    setState(() {
      _errorMessage = null;
    });

    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Бүх талбар бөглөгдсөн үед шалгах
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_isBlocked || _isVerifying) return;

    final enteredCode = _controllers.map((c) => c.text).join();

    // sessionId байвал API-р шалгана
    if (widget.sessionId != null) {
      setState(() => _isVerifying = true);

      try {
        final authService = context.read<AuthService>();
        await authService.verifyOtp(widget.sessionId!, enteredCode);

        if (mounted) {
          setState(() => _isVerifying = false);
          widget.onSuccess();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isVerifying = false;
            _attemptCount++;

            if (_attemptCount >= 5) {
              _isBlocked = true;
              _errorMessage =
                  'Таны эрх түр хаагдлаа. 30 минутын дараа дахин оролдоно уу.';
            } else {
              _errorMessage =
                  'Код буруу байна. Танд ${5 - _attemptCount} удаагийн эрх үлдлээ.';
            }

            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          });
        }
      }
    } else {
      // sessionId байхгүй бол mock validation (legacy)
      if (enteredCode == "1234" || enteredCode == "123456") {
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
                'Код буруу байна. Танд ${5 - _attemptCount} удаагийн эрх үлдлээ.';
          }

          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        });
      }
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
            _otpLength,
            (index) => Row(
              children: [
                _buildCodeField(index, theme, extendedColors),
                if (index < _otpLength - 1) const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        if (_isVerifying) ...[
          const SizedBox(height: 16),
          const Center(child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
        const SizedBox(height: 32),
        Row(
          children: [
            Flexible(
              child: Text(
                l10n.noCodeReceived,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w200,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: widget.onResend,
              child: Text(
                l10n.resendCode,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w400,
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
      enabled: !_isBlocked && !_isVerifying,
      onChanged: (value) => _onChanged(value, index),
    );
  }
}
