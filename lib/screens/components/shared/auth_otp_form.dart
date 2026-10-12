import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _attemptCount = 0;
  bool _isBlocked = false;
  bool _isVerifying = false;
  bool _isClearing = false; // Flag to prevent listener from clearing error on programmatic clear
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChange);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _handleControllerChange() {
    if (_isBlocked || _isVerifying || _isClearing) return;

    setState(() {
      _errorMessage = null;
    });

    if (_controller.text.length == _otpLength) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_isBlocked || _isVerifying) return;

    final enteredCode = _controller.text;
    final l10n = AppLocalizations.of(context)!;

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
              _errorMessage = l10n.yourAccessBlocked;
            } else {
              _errorMessage = l10n.youHaveNTryLeft(5 - _attemptCount);
            }

            // Temporarily flag clearing so listener doesn't wipe out _errorMessage
            _isClearing = true;
            _controller.clear();
            _isClearing = false;

            _focusNode.requestFocus();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Hidden TextField to capture input
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 56,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !_isBlocked && !_isVerifying,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_otpLength),
                  ],
                  autofocus: true,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // Visual representation
            GestureDetector(
              onTap: () {
                if (!_focusNode.hasFocus) {
                  _focusNode.requestFocus();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  _otpLength,
                      (index) {
                    final char = _controller.text.length > index
                        ? _controller.text[index]
                        : '';
                    final isFocused = isKeyboardVisible &&
                        _focusNode.hasFocus &&
                        (_controller.text.length == index ||
                            (_controller.text.length == _otpLength && index == _otpLength - 1));

                    return Row(
                      children: [
                        OtpInputField(
                          value: char,
                          isFocused: isFocused,
                          isError: _errorMessage != null && !_isBlocked,
                          enabled: !_isBlocked && !_isVerifying,
                        ),
                        if (index < _otpLength - 1) const SizedBox(width: 8),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
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
                  color: extendedColors.neutral100,
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
}
