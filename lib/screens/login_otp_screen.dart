import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../widgets/auth/auth_step_app_bar.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
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
      // Success - navigate to biometric setup
      Navigator.pushReplacementNamed(context, '/biometric_setup');
    } else {
      // Failed attempt
      setState(() {
        _attemptCount++;

        if (_attemptCount >= 5) {
          _isBlocked = true;
          _errorMessage =
              'Таны эрх түр хаагдлаа. 30 минутын дараа дахин оролдоно уу.';
        } else {
          _errorMessage = 'Буруу код. ${5 - _attemptCount} оролдлого үлдсэн.';
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
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final channel = args?['channel'] as String? ?? 'SMS';
    final value = args?['value'] as String? ?? '';

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '2/2'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.enterCodeTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.codeSentTo(value, channel),
              style: TextStyle(color: theme.disabledColor, fontSize: 16),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 24,
              children: List.generate(
                4,
                (index) => _buildCodeField(index, theme),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isBlocked
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isBlocked
                        ? theme.colorScheme.error
                        : theme.colorScheme.secondary,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isBlocked ? Icons.block : Icons.warning_amber_rounded,
                      color: _isBlocked
                          ? theme.colorScheme.error
                          : theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: _isBlocked
                              ? theme.colorScheme.error
                              : theme.colorScheme.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  l10n.noCodeReceived,
                  style: TextStyle(color: theme.disabledColor, fontSize: 15),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.resendCode,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeField(int index, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: _isBlocked
            ? (isDark ? colorScheme.surfaceVariant : Colors.grey[100])
            : colorScheme.surface,
        border: Border.all(
          color: _isBlocked
              ? (isDark
                    ? colorScheme.outline.withOpacity(0.5)
                    : Colors.grey[300]!)
              : (_focusNodes[index].hasFocus
                    ? colorScheme.primary
                    : (isDark
                          ? colorScheme.outline.withOpacity(0.2)
                          : Colors.grey[200]!)),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: !_isBlocked,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _isBlocked ? theme.disabledColor : colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: '-',
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
          ),
          onChanged: (value) => _onChanged(value, index),
        ),
      ),
    );
  }
}
