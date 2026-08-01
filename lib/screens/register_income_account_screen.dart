import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/iban_prefix_formatter.dart';
import '../common/payment_webview.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_svg_icon.dart';

class RegisterIncomeAccountScreen extends StatefulWidget {
  const RegisterIncomeAccountScreen({super.key});

  @override
  State<RegisterIncomeAccountScreen> createState() =>
      _RegisterIncomeAccountScreenState();
}

class _RegisterIncomeAccountScreenState
    extends State<RegisterIncomeAccountScreen> {
  // Initialize with empty text so it doesn't display "MN" by default
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  String? _selectedBankCode;
  String _selectedCurrency = 'MNT';
  bool _isButtonEnabled = false;
  bool _isSaving = false;

  /// Хүлээн авагчийн нэр info-оос амжилттай бөглөгдсөн бол засах эрхгүй
  bool _receiverLocked = false;

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
    _recipientController.addListener(_checkFields);
    _loadBanks();
    _fillReceiverFromInfo();
  }

  /// Хүлээн авагчийн нэрийг хэрэглэгчийн info-оос шууд бөглөнө.
  /// (Бүртгэлийн явцад info байхгүй бол гараар бичих боломж үлдэнэ.)
  Future<void> _fillReceiverFromInfo() async {
    final auth = context.read<AuthService>();
    Map<String, dynamic>? info = auth.userInfo;
    if (info == null && auth.isAuthenticated) {
      info = await auth.refreshUserInfo();
    }
    if (!mounted || info == null) return;
    final name =
        '${info['lastName'] ?? ''} ${info['firstName'] ?? ''}'.trim();
    if (name.isNotEmpty) {
      setState(() {
        _recipientController.text = name;
        _receiverLocked = true;
      });
      _checkFields();
    }
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
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final auth = context.read<AuthService>();
      final list = await auth.getBanksList();
      if (!mounted) return;
      // Кодоор эрэмбэлнэ ("01", "04", ...)
      list.sort(
        (a, b) => (a['code']?.toString() ?? '').compareTo(
          b['code']?.toString() ?? '',
        ),
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
        currency: _selectedCurrency,
      );
      if (!mounted) return;

      // Данс нээлгэх хураамж — банк сонгох дэлгэцийн оронд NEGDI линкийг
      // app доторх webview-ээр шууд нээж, амжилттай болмогц дараагийн
      // алхам руу шилжинэ
      // homeRoute — төлбөрийн хуудас `mandalapp://home` эсвэл
      // `MandalApp.postMessage(...)`-ээр шууд register_success руу шилжинэ
      final result = await openPaymentWebview(
        context,
        amount: 5000,
        homeRoute: '/register_success',
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (result == 'success') {
        Navigator.pushNamed(context, '/register_success', arguments: args);
      } else if (result != null) {
        CustomSnackbar.show(
          context,
          message: 'Төлбөр амжилтгүй боллоо',
          type: CustomSnackbarType.error,
        );
      }
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: const AuthStepAppBar(stepText: '3/4'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.enterIncomeAccount,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.enterIncomeAccountSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral200,
              ),
            ),
            const SizedBox(height: 48),
            CustomInput(
              label: l10n.ibanNumber,
              hint: '',
              controller: _ibanController,
              inputFormatters: [IbanPrefixFormatter()],
              suffix: Padding(
                padding: const EdgeInsets.only(left: 18),
                child: CustomSvgIcon('copy-06', size: 24,),
              ),
            ),
            const SizedBox(height: 16),
            if (_banksLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomDropdown<String>(
                      label: l10n.bankName,
                      value: _selectedBankCode,
                      items: _banks.map((bank) {
                        final code = bank['code']?.toString() ?? '';
                        final name = bank['name']?.toString() ?? code;
                        return DropdownMenuItem<String>(
                          value: code,
                          child: Text(name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBankCode = newValue;
                          _checkFields();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomDropdown<String>(
                      label: l10n.currencyLabel,
                      value: _selectedCurrency,
                      items: const [
                        DropdownMenuItem(value: 'MNT', child: Text('MNT')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        setState(() => _selectedCurrency = newValue);
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Хүлээн авагч — info-оос автоматаар бөглөгдсөн бол засах эрхгүй
            CustomInput(
              label: l10n.recipientName,
              hint: '',
              controller: _recipientController,
              enabled: !_receiverLocked,
            ),
            if (!_receiverLocked) ...[
              const SizedBox(height: 16),
              Text(
                l10n.lastNameOrFirstNameNote,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: extendedColors.neutral200,
                ),
              ),
            ],
            const SizedBox(height: 48),
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
