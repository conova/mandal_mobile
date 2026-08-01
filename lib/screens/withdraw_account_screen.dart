import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/api_message.dart';
import '../common/stock_row_format.dart';
import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/income_account.dart';
import '../services/api_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/initial_avatar.dart';

/// Зарлага гаргах — хүлээн авах данс сонгох дэлгэц.
///
/// Args: { currency: 'mnt'|'usd', amount: double, rate: double }
///   • rate — 1 нэгж валютын ₮ ханш (usd үед ≈₮ дүн харуулахад)
class WithdrawAccountScreen extends StatefulWidget {
  const WithdrawAccountScreen({super.key});

  @override
  State<WithdrawAccountScreen> createState() => _WithdrawAccountScreenState();
}

class _WithdrawAccountScreenState extends State<WithdrawAccountScreen> {
  bool _isLoading = true;
  List<IncomeAccount> _accounts = [];
  String? _selectedAccountNo;

  // Банкны кодоор ялгах avatar-ийн өнгө (лого asset байхгүй тул)
  static const Map<String, Color> _bankColors = {
    '04': Color(0xFF1E5FA8), // ХХБ
    '05': Color(0xFF2D5F3E), // ХААН
    '15': Color(0xFF3F51B5), // Голомт
    '30': Color(0xFF0277BD), // Капитрон
    '32': Color(0xFFFF6B35), // Хас
    '34': Color(0xFF1B4B7F), // Төрийн
    '38': Color(0xFF6A1B9A), // Богд
    '39': Color(0xFF00BFA5), // М банк
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchAccounts);
  }

  Future<void> _fetchAccounts() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await context.read<ApiService>().get(ApiConfig.userAccounts);
      final body = response.data;
      if (!mounted) return;
      if (body is Map && body['code']?.toString() == '0') {
        final data = body['data'];
        final accounts = data is List
            ? data
                .whereType<Map>()
                .map((e) => IncomeAccount.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <IncomeAccount>[];
        setState(() {
          _accounts = accounts;
          // Үндсэн (эсвэл эхний) дансыг автоматаар сонгоно
          if (accounts.isNotEmpty) {
            _selectedAccountNo = accounts
                .firstWhere((a) => a.isPrimary, orElse: () => accounts.first)
                .accountNumber;
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        CustomSnackbar.show(
          context,
          message: apiMessage(body) ?? 'Данс татахад алдаа гарлаа',
          type: CustomSnackbarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  void _handleWithdraw() {
    if (_selectedAccountNo == null) return;
    // TODO: зарлага гаргах API бэлэн болмогц энд холбоно
    Navigator.pushReplacementNamed(context, '/withdraw_success');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final lang = Localizations.localeOf(context).languageCode;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final isMnt = args['currency']?.toString() != 'usd';
    final amount = (args['amount'] as num?)?.toDouble() ?? 0;
    final rate = (args['rate'] as num?)?.toDouble() ?? 0;

    // "50.00$" → бүхэл хэсэг бараан, бутархай + тэмдэгт нь бүдэг
    final formatted = formatStockAmount(amount, isForeign: !isMnt, decimals: 2);
    final dotIdx = formatted.indexOf('.');
    final whole = dotIdx == -1 ? formatted : formatted.substring(0, dotIdx);
    final fraction = dotIdx == -1 ? '' : formatted.substring(dotIdx);

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header — буцах товч + голдоо дүн
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CircleBackButton(),
                  ),
                ),
              ],
            ),
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.withdrawAmountTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
              ],
            )
            ,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  whole,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                if (fraction.isNotEmpty)
                  Text(
                    fraction,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral300,
                    ),
                  ),
              ],
            ),
            if (!isMnt && rate > 0) ...[
              const SizedBox(height: 8),
              Text(
                '≈${formatStockAmount(amount * rate, decimals: 2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Divider(height: 1, color: extendedColors.neutral500),
            // Данс сонгох хэсэг
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.receiveAccount,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: extendedColors.neutral100,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (final account in _accounts) ...[
                            _buildAccountCard(
                              account,
                              theme,
                              extendedColors,
                              lang,
                            ),
                            const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 16),
                          // Данс нэмэх
                          Center(
                            child: TextButton.icon(
                              onPressed: () async {
                                final added = await Navigator.pushNamed(
                                  context,
                                  '/add_income_account',
                                );
                                if (added == true) _fetchAccounts();
                              },
                              icon: Icon(
                                Icons.add,
                                color: extendedColors.primaryMain,
                              ),
                              label: Text(
                                l10n.addAccountLabel,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: extendedColors.primaryMain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Divider(height: 1, color: extendedColors.neutral500),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.makeWithdraw,
                  onPressed:
                      _selectedAccountNo != null ? _handleWithdraw : null,
                  variant: CustomButtonVariant.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    IncomeAccount account,
    ThemeData theme,
    ExtendedColors extendedColors,
    String lang,
  ) {
    final isSelected = _selectedAccountNo == account.accountNumber;
    final bankName = account.localizedBankName(lang);
    final avatarColor =
        _bankColors[account.bankCode] ?? extendedColors.primaryMain;

    return GestureDetector(
      onTap: () => setState(() => _selectedAccountNo = account.accountNumber),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? extendedColors.primaryMain
                : extendedColors.neutral500,
          ),
        ),
        child: Row(
          children: [
            // Банкны лого — server-ээс (алдаа гарвал үсэгтэй avatar fallback)
            ClipOval(
              child: Image.network(
                ApiConfig.bankLogoUrl(account.bankCode),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => InitialAvatar(
                  initial:
                      bankName.isNotEmpty ? bankName[0].toUpperCase() : '?',
                  color: avatarColor,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.curCode.isNotEmpty
                        ? '${account.accountNumber} ${account.curCode}'
                        : account.accountNumber,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bankName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Radio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? extendedColors.primaryMain
                      : extendedColors.neutral400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: extendedColors.primaryMain,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
