import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/auth/auth_step_app_bar.dart';

class RegisterIncomeAccountScreen extends StatefulWidget {
  const RegisterIncomeAccountScreen({super.key});

  @override
  State<RegisterIncomeAccountScreen> createState() => _RegisterIncomeAccountScreenState();
}

class _RegisterIncomeAccountScreenState extends State<RegisterIncomeAccountScreen> {
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  String? _selectedBank;
  bool _isButtonEnabled = false;

  final List<String> _banks = [
    'Хаан банк',
    'Голомт банк',
    'Төрийн банк',
    'Худалдаа хөгжлийн банк',
    'Капитрон банк',
  ];

  @override
  void initState() {
    super.initState();
    _ibanController.addListener(_checkFields);
    _recipientController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _ibanController.text.isNotEmpty &&
          _recipientController.text.isNotEmpty &&
          _selectedBank != null;
    });
  }

  void _handleSave() {
    if (!_isButtonEnabled) return;
    // Navigate to bank selection screen
    Navigator.pushNamed(context, '/register_bank_selection');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '3/5'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.enterIncomeAccount,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.enterIncomeAccountSubtitle,
              style: TextStyle(color: theme.disabledColor, fontSize: 16),
            ),
            const SizedBox(height: 48),
            CustomInput(
              label: l10n.ibanNumber,
              hint: '',
              controller: _ibanController,
              suffix: Icon(Icons.copy_outlined, color: theme.disabledColor, size: 20),
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: l10n.bankName,
              value: _selectedBank,
              items: _banks.map((String bank) {
                return DropdownMenuItem<String>(
                  value: bank,
                  child: Text(bank),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBank = newValue;
                  _checkFields();
                });
              },
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: l10n.recipientName,
              hint: '',
              controller: _recipientController,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.lastNameOrFirstNameNote,
              style: TextStyle(color: theme.disabledColor, fontSize: 13),
            ),
            const Spacer(),
            CustomButton(
              label: l10n.save,
              onPressed: _isButtonEnabled ? _handleSave : null,
              variant: CustomButtonVariant.primary,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
