import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import 'income_method_screen.dart' show AccountTypeRow;
import '../widgets/custom_snackbar.dart';

class WithdrawMethodScreen extends StatefulWidget {
  const WithdrawMethodScreen({super.key});

  @override
  State<WithdrawMethodScreen> createState() => _WithdrawMethodScreenState();
}

class _WithdrawMethodScreenState extends State<WithdrawMethodScreen> {
  /// Боломжит үлдэгдэл — /portfolio/breakdown-ийн mnt/usd мөрөөс
  double _mntBalance = 0;
  double _usdBalance = 0;

  /// 1 USD-ийн ₮ ханш — breakdown-ийн usd мөрийн amountMnt/amount
  double _usdRate = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchBalances);
  }

  Future<void> _fetchBalances() async {
    try {
      final breakdown = await context.read<AuthService>().getAssetBreakdown();
      if (!mounted) return;
      double byType(String type) {
        final row = breakdown.firstWhere(
          (b) => b['type']?.toString() == type,
          orElse: () => const {},
        );
        return (row['amount'] as num?)?.toDouble() ?? 0;
      }

      double byKey(String type, String key) {
        final row = breakdown.firstWhere(
          (b) => b['type']?.toString() == type,
          orElse: () => const {},
        );
        return (row[key] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        _mntBalance = byType('mnt');
        _usdBalance = byType('usd');
        final usdMnt = byKey('usd', 'amountMnt');
        _usdRate = _usdBalance > 0 ? usdMnt / _usdBalance : 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  void _onOptionTap({required bool isMnt, String account = 'stock'}) {
    if (_isLoading) return;
    final balance = isMnt ? _mntBalance : _usdBalance;
    if (balance <= 0) {
      // Үлдэгдэлгүй — дараагийн алхам руу оруулахгүй toast харуулна
      CustomSnackbar.show(
        context,
        message: isMnt
            ? 'Төгрөгийн үлдэгдэл байхгүй байна'
            : 'Долларын үлдэгдэл байхгүй байна',
        type: CustomSnackbarType.info,
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/withdraw_amount',
      arguments: {
        'currency': isMnt ? 'mnt' : 'usd',
        'account': account,
        'balance': balance,
        'rate': isMnt ? 1.0 : _usdRate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.makeWithdraw,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.withdrawMethodDesc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // ₮ данснууд — Хувьцаа, Бонд
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.mntAccounts,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AccountTypeRow(
              icon: 'tugrug-01',
              iconBg: extendedColors.primary100,
              iconColor: extendedColors.primaryMain,
              title: l10n.stocks,
              balanceLabel: l10n.availableBalanceLabel,
              balance: formatStockAmount(_mntBalance, decimals: 0),
              isLoading: _isLoading,
              onTap: () => _onOptionTap(isMnt: true, account: 'stock'),
            ),
            Divider(height: 1, color: extendedColors.neutral500),
            AccountTypeRow(
              icon: 'tugrug-01',
              iconBg: extendedColors.primaryMain,
              iconColor: Colors.white,
              title: l10n.bond,
              balanceLabel: l10n.availableBalanceLabel,
              balance: formatStockAmount(_mntBalance, decimals: 0),
              isLoading: _isLoading,
              onTap: () => _onOptionTap(isMnt: true, account: 'bond'),
            ),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 28),
            // $ данс
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.usdAccounts,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AccountTypeRow(
              icon: 'currency-dollar',
              iconBg: extendedColors.neutral100,
              iconColor: extendedColors.bgBase,
              title: l10n.dollar,
              balanceLabel: l10n.availableBalanceLabel,
              balance: formatStockAmount(
                _usdBalance,
                isForeign: true,
                decimals: 0,
              ),
              isLoading: _isLoading,
              onTap: () => _onOptionTap(isMnt: false, account: 'usd'),
            ),
            Divider(height: 1, color: extendedColors.neutral500),
          ],
        ),
      ),
    );
  }

}
