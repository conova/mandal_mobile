import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';

/// Бондын данс цэнэглэх — банкны шилжүүлгийн мэдээлэл (МҮЦТХ данс руу).
///
/// Route args (бүгд optional — өгөгдвөл дарж харуулна):
///   { iban: String, amount: num, receiver: String, memo: String }
/// TODO: IBAN/гүйлгээний утгын бодит API холбогдмогц эндээс авна
class DepositInfoScreen extends StatelessWidget {
  const DepositInfoScreen({super.key});

  /// МҮЦТХ — банкны код 95 (лого server-ээс)
  static const String _bankCode = '95';
  static const String _bankName = 'Монголын үнэт цаасны төвлөрсөн хадгаламж';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final auth = context.read<AuthService>();
    final info = auth.userInfo;

    final iban = args['iban']?.toString() ?? '';
    final amount = (args['amount'] as num?)?.toDouble();
    final receiver = args['receiver']?.toString() ??
        '${info?['lastName'] ?? ''} ${info?['firstName'] ?? ''}'.trim();
    final memo = args['memo']?.toString() ?? auth.uid ?? '';

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
                        style: theme.textTheme.headlineLarge?.copyWith(
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
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: extendedColors.neutral200,
                          ),
                        ),
                      )
                    ),
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: l10n.receiverBank,
                            value: _bankName,
                            trailing: ClipOval(
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(4),
                                child: Image.network(
                                  ApiConfig.bankLogoUrl(_bankCode),
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
                          _InfoRow(
                            label: l10n.ibanAccountNo,
                            value: iban.isNotEmpty ? iban : '-',
                            copyValue: iban,
                          ),
                          if (amount != null)
                            _InfoRow(
                              label: l10n.transferAmount,
                              value: formatStockAmount(amount, decimals: 2),
                              copyValue: amount.toStringAsFixed(2),
                            ),
                          _InfoRow(
                            label: l10n.receiver,
                            value: receiver.isNotEmpty ? receiver : '-',
                            copyValue: receiver,
                          ),
                          _InfoRow(
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? copyValue;
  final Widget? trailing;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.copyValue,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: EdgeInsets.only(top: 14, bottom: isLast ? 14 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (trailing != null)
            trailing!
          else if (copyValue != null && copyValue!.isNotEmpty)
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyValue!));
                CustomSnackbar.show(context, message: l10n.copiedLabel);
              },
              icon: CustomSvgIcon(
                'copy-06',
                size: 26,
                color: extendedColors.primaryMain,
              ),
            ),
        ],
      ),
    );
  }
}
