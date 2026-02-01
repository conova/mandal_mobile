import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import 'components/register/register_bank_list.dart';

class RegisterBankSelectionScreen extends StatefulWidget {
  const RegisterBankSelectionScreen({super.key});

  @override
  State<RegisterBankSelectionScreen> createState() =>
      _RegisterBankSelectionScreenState();
}

class _RegisterBankSelectionScreenState
    extends State<RegisterBankSelectionScreen> {
  String? _selectedBank;

  final List<Map<String, dynamic>> _banks = [
    {'name': 'Хаан банк', 'icon': '🏦', 'color': const Color(0xFF2D5F3E)},
    {
      'name': 'Худалдаа хөгжлийн банк',
      'icon': '🏦',
      'color': const Color(0xFF1E5FA8),
    },
    {'name': 'M bank', 'icon': '🏦', 'color': const Color(0xFF00BFA5)},
    {'name': 'Хас банк', 'icon': '🏦', 'color': const Color(0xFFFF6B35)},
    {'name': 'Төрийн банк', 'icon': '🏦', 'color': const Color(0xFF1B4B7F)},
  ];

  void _handleContinue() {
    if (_selectedBank == null) return;
    // Navigate to success screen
    Navigator.pushNamed(context, '/register_success');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '4/5'),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.selectYourBank,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '₮5,000',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: RegisterBankList(
              banks: _banks,
              selectedBank: _selectedBank,
              onSelect: (bankName) {
                setState(() {
                  _selectedBank = bankName;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomButton(
              label: l10n.selectBankToContinue,
              onPressed: _selectedBank != null ? _handleContinue : null,
              variant: CustomButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }
}
