import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
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
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '4/5'),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.selectYourBank,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₮5,000',
            style: theme.textTheme.displayMedium?.copyWith(
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
