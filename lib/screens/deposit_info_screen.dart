import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/api_message.dart';
import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/income_account.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import 'components/shared/deposit_info_row.dart';

/// Данс цэнэглэх — банкны шилжүүлгийн мэдээлэл.
///
/// Харилцагчийн дансны жагсаалтаас (/user/acnts) банкны кодоор нь
/// хүлээн авах дансыг олж харуулна. Тийм данс бүртгэгдээгүй бол
/// анхааруулаад буцна.
class DepositInfoScreen extends StatefulWidget {
  const DepositInfoScreen({super.key});

  @override
  State<DepositInfoScreen> createState() => _DepositInfoScreenState();
}

class _DepositInfoScreenState extends State<DepositInfoScreen> {
  /// Хүлээн авах дансны банкны код (TXNBANKNO)
  static const String _targetBankCode = '95';

  bool _isLoading = true;
  IncomeAccount? _account;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchAccount);
  }

  Future<void> _fetchAccount() async {
    try {
      final response =
          await context.read<ApiService>().get(ApiConfig.userAccounts);
      if (!mounted) return;
      final body = response.data;

      IncomeAccount? match;
      if (body is Map &&
          body['code']?.toString() == '0' &&
          body['data'] is List) {
        for (final row in (body['data'] as List).whereType<Map>()) {
          final account =
              IncomeAccount.fromJson(Map<String, dynamic>.from(row));
          if (account.bankCode.trim() == _targetBankCode) {
            match = account;
            break;
          }
        }
      } else if (body is Map) {
        throw Exception(apiMessage(body) ?? 'Данс татахад алдаа гарлаа');
      }

      if (match == null) {
        // Шилжүүлэг хүлээн авах данс бүртгэгдээгүй байна
        CustomSnackbar.show(
          context,
          message: AppLocalizations.of(context)!.completeRegistrationPrompt,
          type: CustomSnackbarType.error,
        );
        Navigator.pop(context);
        return;
      }

      setState(() {
        _account = match;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final lang = Localizations.localeOf(context).languageCode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: extendedColors.bgBase,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircleBackButton(),
                ),
              ),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      );
    }

    final info = context.read<AuthService>().userInfo;
    final account = _account;

    // Хүлээн авагч — дансны эзэмшигчийн нэр, байхгүй бол профайлаас
    final receiver = (account?.accountName.isNotEmpty ?? false)
        ? account!.accountName
        : '${info?['lastName'] ?? ''} ${info?['firstName'] ?? ''}'.trim();
    // Гүйлгээний утга — харилцагчийг ялгах регистрийн дугаар, утас
    final memo = [
      info?['registerNumber']?.toString() ?? '',
      info?['phone']?.toString() ?? '',
    ].where((v) => v.isNotEmpty).join(', ');
    final iban = account?.accountNumber ?? '';

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CircleBackButton(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        l10n.bondDepositTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
                        child: Text(
                          l10n.depositInfoSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: extendedColors.neutral200,
                          ),
                        ),
                      )
                    ),
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          DepositInfoRow(
                            label: l10n.receiverBank,
                            value: account?.localizedBankName(lang) ?? '-',
                            trailing: ClipOval(
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(4),
                                child: Image.network(
                                  ApiConfig.bankLogoUrl(
                                    account?.bankCode ?? '',
                                  ),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.account_balance,
                                    size: 32,
                                    color: extendedColors.neutral200,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DepositInfoRow(
                            label: l10n.ibanAccountNo,
                            value: iban.isNotEmpty ? iban : '-',
                            // Банкны апп руу буулгахад зай саад болохгүй
                            copyValue: iban.replaceAll(' ', ''),
                          ),
                          DepositInfoRow(
                            label: l10n.receiver,
                            value: receiver.isNotEmpty ? receiver : '-',
                            copyValue: receiver,
                          ),
                          DepositInfoRow(
                            label: l10n.transactionMemo,
                            value: memo.isNotEmpty ? memo : '-',
                            copyValue: memo,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: extendedColors.neutral500),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.finish,
                  onPressed: () => _finish(context),
                  variant: CustomButtonVariant.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Үндсэн дэлгэц рүү буцна (stack-д /main байвал popUntil)
  void _finish(BuildContext context) {
    var mainFound = false;
    Navigator.popUntil(context, (route) {
      if (route.settings.name == '/main') {
        mainFound = true;
        return true;
      }
      return route.isFirst;
    });
    if (!mainFound) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }
}
