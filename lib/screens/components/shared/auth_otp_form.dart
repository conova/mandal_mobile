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

  /// Hidden TextField үргэлж энэ тэмдэгтийг агуулна. Ингэснээр хоосон байхад ч
  /// backspace дарсныг мэдэж болно (текст богино болбол backspace).
  static const String _sentinel = '\u200B';

  final TextEditingController _controller =
  TextEditingController(text: _sentinel);
  final FocusNode _focusNode = FocusNode();

  /// Код нь үргэлж 4 нүдтэй. Хоосон нүд = ''
  final List<String> _digits = List.filled(_otpLength, '');
  int _activeIndex = 0;

  int _attemptCount = 0;
  bool _isBlocked = false;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _resetHiddenField();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  bool get _enabled => !_isBlocked && !_isVerifying;

  bool get _isComplete => _digits.every((d) => d.isNotEmpty);

  int get _firstEmptyIndex {
    final i = _digits.indexWhere((d) => d.isEmpty);
    return i == -1 ? _otpLength - 1 : i;
  }

  void _resetHiddenField() {
    _controller.value = const TextEditingValue(
      text: _sentinel,
      selection: TextSelection.collapsed(offset: _sentinel.length),
    );
  }

  /// Нүд дээр дарахад тэр нүдийг идэвхжүүлнэ.
  /// Бөглөгдсөн нүдийг дарвал дараагийн бичсэн тоо түүнийг солино.
  /// Хоосон нүдүүдийг алгасаж болохгүй тул эхний хоосон нүд рүү шилжинэ.
  void _onBoxTap(int index) {
    if (!_enabled) return;

    setState(() {
      _activeIndex = index.clamp(0, _firstEmptyIndex);
    });
    _focusNode.requestFocus();
  }

  void _onInputChanged(String value) {
    if (!_enabled) {
      _resetHiddenField();
      return;
    }

    if (value.length < _sentinel.length) {
      _handleBackspace();
    } else {
      final typed = value.replaceAll(_sentinel, '');
      final newDigits = typed.replaceAll(RegExp(r'[^0-9]'), '');
      if (newDigits.isNotEmpty) {
        _handleDigits(newDigits);
      }
    }

    _resetHiddenField();
  }

  /// Тоо бичихэд идэвхтэй нүдийг СОЛИНО (урт өөрчлөгдөхгүй), дараа нь дараагийн нүд рүү шилжинэ.
  void _handleDigits(String input) {
    setState(() {
      _errorMessage = null;
      for (final ch in input.split('')) {
        _digits[_activeIndex] = ch;
        if (_activeIndex < _otpLength - 1) _activeIndex++;
      }
    });

    if (_isComplete) _verifyOtp();
  }

  /// Backspace: идэвхтэй нүд бөглөгдсөн бол зөвхөн түүнийг арилгана.
  /// Хоосон бол өмнөх нүд рүү очиж түүнийг арилгана.
  void _handleBackspace() {
    setState(() {
      _errorMessage = null;
      if (_digits[_activeIndex].isNotEmpty) {
        _digits[_activeIndex] = '';
      } else if (_activeIndex > 0) {
        _activeIndex--;
        _digits[_activeIndex] = '';
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_isBlocked || _isVerifying) return;

    final enteredCode = _digits.join();
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

            for (var i = 0; i < _otpLength; i++) {
              _digits[i] = '';
            }
            _activeIndex = 0;
          });

          _resetHiddenField();
          _focusNode.requestFocus();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Hidden TextField to capture keyboard input
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 56,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: _enabled,
                  keyboardType: TextInputType.number,
                  onChanged: _onInputChanged,
                  autofocus: false,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // Visual representation
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                _otpLength,
                    (index) {
                  final isFocused =
                      _focusNode.hasFocus && index == _activeIndex;

                  return Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onBoxTap(index),
                        child: OtpInputField(
                          value: _digits[index],
                          isFocused: isFocused,
                          isError: _errorMessage != null && !_isBlocked,
                          enabled: _enabled,
                        ),
                      ),
                      if (index < _otpLength - 1) const SizedBox(width: 8),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        if (_isVerifying) ...[
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
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