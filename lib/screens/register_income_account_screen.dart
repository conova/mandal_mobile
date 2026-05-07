import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/auth/auth_step_app_bar.dart';

class RegisterIncomeAccountScreen extends StatefulWidget {
  const RegisterIncomeAccountScreen({super.key});

  @override
  State<RegisterIncomeAccountScreen> createState() =>
      _RegisterIncomeAccountScreenState();
}

class _RegisterIncomeAccountScreenState
    extends State<RegisterIncomeAccountScreen> {
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  String? _selectedBankCode;
  bool _isButtonEnabled = false;
  bool _isSaving = false;

  // Банкны жагсаалт ({ code, name })
  List<Map<String, dynamic>> _banks = const [];
  bool _banksLoading = true;

  // Fallback: API амжилтгүй үед ашиглах
  static const List<Map<String, dynamic>> _fallbackBanks = [
    {'code': 'KHB', 'name': 'Хаан банк'},
    {'code': 'GLB', 'name': 'Голомт банк'},
    {'code': 'STB', 'name': 'Төрийн банк'},
    {'code': 'TDB', 'name': 'Худалдаа хөгжлийн банк'},
    {'code': 'CAP', 'name': 'Капитрон банк'},
  ];

  @override
  void initState() {
    super.initState();
    _ibanController.addListener(_checkFields);
    _recipientController.addListener(_checkFields);
    _loadBanks();
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final auth = context.read<AuthService>();
      final list = await auth.getBanksList();
      if (!mounted) return;
      setState(() {
        _banks = list.isNotEmpty ? list : _fallbackBanks;
        _banksLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _banks = _fallbackBanks;
        _banksLoading = false;
      });
    }
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled =
          _ibanController.text.isNotEmpty &&
          _recipientController.text.isNotEmpty &&
          _selectedBankCode != null;
    });
  }

  Future<void> _handleSave() async {
    if (!_isButtonEnabled || _isSaving) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final sessionId = args['sessionId'] as String?;
    if (sessionId == null) {
      CustomSnackbar.show(
        context,
        message: 'Session ID олдсонгүй. Дахин эхэлнэ үү.',
        type: CustomSnackbarType.error,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthService>();
      await auth.addAccount(
        sessionId: sessionId,
        bankCode: _selectedBankCode!,
        iban: _ibanController.text.trim(),
        accountName: _recipientController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      Navigator.pushNamed(
        context,
        '/register_bank_selection',
        arguments: args,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.enterIncomeAccountSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: extendedColors.neutral500,
              ),
            ),
            const SizedBox(height: 48),
            CustomInput(
              label: l10n.ibanNumber,
              hint: '',
              controller: _ibanController,
              suffix: Icon(
                Icons.copy_outlined,
                color: extendedColors.neutral400,
                size: 20,
              ),
            ),
            const SizedBox(height: 16),
            if (_banksLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              CustomDropdown<String>(
                label: l10n.bankName,
                value: _selectedBankCode,
                items: _banks.map((bank) {
                  final code = bank['code']?.toString() ?? '';
                  final name = bank['name']?.toString() ?? code;
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBankCode = newValue;
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
              style: theme.textTheme.labelLarge?.copyWith(
                color: extendedColors.neutral500,
              ),
            ),
            const Spacer(),
            CustomButton(
              label: l10n.save,
              onPressed: (_isButtonEnabled && !_isSaving) ? _handleSave : null,
              isLoading: _isSaving,
              variant: CustomButtonVariant.primary,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
