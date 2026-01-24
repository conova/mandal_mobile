import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ChangePasswordCodeScreen extends StatefulWidget {
  const ChangePasswordCodeScreen({super.key});

  @override
  State<ChangePasswordCodeScreen> createState() => _ChangePasswordCodeScreenState();
}

class _ChangePasswordCodeScreenState extends State<ChangePasswordCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

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
      Navigator.pushNamed(context, '/change_password_new');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final channel = args['channel'] as String;
    final value = args['value'] as String;

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
                '1/2',
                style: TextStyle(
                  color: theme.disabledColor,
                  fontWeight: FontWeight.bold,
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
              l10n.enterCodeTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.codeSentTo(channel, value),
              style: TextStyle(color: theme.disabledColor, fontSize: 16),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => _buildCodeField(index, theme)),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  l10n.noCodeReceived,
                  style: TextStyle(color: theme.disabledColor),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.resendCode,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
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
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _focusNodes[index].hasFocus ? theme.primaryColor : theme.dividerColor.withOpacity(0.1),
          width: 2,
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            hintText: '-',
            hintStyle: TextStyle(color: Colors.black26),
          ),
          onChanged: (value) => _onChanged(value, index),
        ),
      ),
    );
  }
}
