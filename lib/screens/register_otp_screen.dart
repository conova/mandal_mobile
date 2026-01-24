import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_step_app_bar.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

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
    // Navigate to password creation screen
    Navigator.pushNamed(context, '/register_password');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final phone = args['phone'] as String;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '1/4'),
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
              'Таны $phone дугаарт код илгээлээ.',
              style: TextStyle(color: theme.disabledColor, fontSize: 16),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 24,
              children: List.generate(4, (index) => _buildCodeField(index, colorScheme)),
            ),
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
                      color: colorScheme.primary,
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

  Widget _buildCodeField(int index, ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: _focusNodes[index].hasFocus ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
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
