import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../common/iban_prefix_formatter.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';

class AddIncomeAccountScreen extends StatefulWidget {
  const AddIncomeAccountScreen({super.key});

  @override
  State<AddIncomeAccountScreen> createState() => _AddIncomeAccountScreenState();
}

class _AddIncomeAccountScreenState extends State<AddIncomeAccountScreen> {
  // Initialize with empty text so it doesn't display "MN" by default
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  String? _selectedBankCode;
  bool _isButtonEnabled = false;
  bool _isSaving = false;

  // Банкны жагсаалт ({ code, name })
  List<Map<String, dynamic>> _banks = const [];
  bool _banksLoading = true;

  // Fallback: API амжилтгүй үед ашиглах (/banks/list-ийн бодит хуулбар,
  // кодоор эрэмбэлсэн)
  static const List<Map<String, dynamic>> _fallbackBanks = [
    {'code': '01', 'name': 'Төв Монголбанк'},
    {'code': '04', 'name': 'Худалдаа хөгжлийн банк'},
    {'code': '05', 'name': 'ХААН Банк'},
    {'code': '15', 'name': 'Голомт банк'},
    {'code': '19', 'name': 'Тээвэр хөгжлийн банк'},
    {'code': '21', 'name': 'Ариг банк'},
    {'code': '22', 'name': 'Кредит банк'},
    {'code': '29', 'name': 'Үндэсний хөрөнгө оруулалтын банк'},
    {'code': '30', 'name': 'Капитрон банк'},
    {'code': '32', 'name': 'Хас банк'},
    {'code': '33', 'name': 'Чингис хаан банк'},
    {'code': '34', 'name': 'Төрийн банк'},
    {'code': '36', 'name': 'Хөгжлийн банк'},
    {'code': '38', 'name': 'Богд банк'},
    {'code': '39', 'name': 'М Банк'},
    {'code': '50', 'name': 'МОБИФИНАНС ББСБ'},
    {'code': '52', 'name': 'Ард Кредит ББСБ'},
    {'code': '90', 'name': 'Төрийн сан'},
    {'code': '91', 'name': 'НОАТ буцаан олголт'},
    {'code': '94', 'name': 'Монголын үнэт цаасны клирингийн төв'},
    {'code': '95', 'name': 'ҮЦ Төвлөрсөн Хадгаламжийн төв'},
  ];

  @override
  void initState() {
    super.initState();
    _ibanController.addListener(_onIbanChanged);
    _receiverController.addListener(_checkFields);
    _loadBanks();
  }

  void _onIbanChanged() {
    _autoDetectBank();
    _checkFields();
  }

  /// IBAN-аас банкыг автоматаар таньж сонгоно.
  /// MN + 2 орон (check) + 2 орон (банкны код): MN97**00**15... → банк "15".
  /// Тоон дугаараар нь харьцуулдаг тул "04" == "4" гэж таарна.
  void _autoDetectBank() {
    final text = _ibanController.text;
    if (text.length < 8) return;
    final code = int.tryParse(text.substring(6, 8));
    if (code == null) return;
    for (final bank in _banks) {
      if (int.tryParse(bank['code']?.toString() ?? '') == code) {
        final bankCode = bank['code']?.toString();
        if (bankCode != _selectedBankCode) {
          setState(() => _selectedBankCode = bankCode);
        }
        return;
      }
    }
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final auth = context.read<AuthService>();
      final list = await auth.getBanksList();
      if (!mounted) return;
      // Кодоор эрэмбэлнэ ("01", "04", ...)
      list.sort((a, b) => (a['code']?.toString() ?? '')
            .compareTo(b['code']?.toString() ?? ''),
      );
      setState(() {
        _banks = list.isNotEmpty ? list : _fallbackBanks;
        _banksLoading = false;
      });
      // IBAN аль хэдийн бичигдсэн байвал банкыг шууд таниулна
      _autoDetectBank();
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
      // IBAN нь "MN" угтвараас гадна утга агуулсан байх ёстой
      _isButtonEnabled =
        _ibanController.text.length > IbanPrefixFormatter.prefix.length &&
          _receiverController.text.isNotEmpty &&
          _selectedBankCode != null;
  });
  }

  Future<void> _handleSave() async {
    if (!_isButtonEnabled || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthService>();
      // Нэвтэрсэн хэрэглэгч тул sessionId дамжуулахгүй — Bearer token явна
      final message = await auth.addAccount(
        bankCode: _selectedBankCode!,
        iban: _ibanController.text.trim(),
        accountName: _receiverController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      CustomSnackbar.show(context, message: message);
      // true буцааж дансны жагсаалтыг шинэчлүүлнэ
      Navigator.pop(context, true);
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircleBackButton(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                l10n.addIncomeAccPrompt,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.incomeAccBenefitPrompt,
                style: TextStyle(color: theme.disabledColor, fontSize: 14),
              ),
              const SizedBox(height: 40),
              CustomInput(
                label: l10n.iban,
                controller: _ibanController,
                inputFormatters: [IbanPrefixFormatter()],
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: CustomSvgIcon('copy-06', size: 24,),
                ),
              ),
              const SizedBox(height: 20),
              if (_banksLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                CustomDropdown<String>(
                  label: l10n.bank,
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
              const SizedBox(height: 20),
              CustomInput(
                label: l10n.receiver,
                controller: _receiverController,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.receiverHint,
                style: TextStyle(color: theme.disabledColor, fontSize: 12),
              ),
              const SizedBox(height: 60),
              CustomButton(
                label: l10n.save,
                onPressed:
                (_isButtonEnabled && !_isSaving) ? _handleSave : null,
                isLoading: _isSaving,
                variant: CustomButtonVariant.primary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
