import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';

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

  void _onOptionTap({required bool isMnt}) {
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
                l10n.expense,
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
            const SizedBox(height: 32),
            // Tugrik option
            _buildMethodOption(
              theme: theme,
              extendedColors: extendedColors,
              icon: 'tugrug-01',
              title: l10n.tugrik,
              balanceLabel: formatStockAmount(_mntBalance, decimals: 2),
              hasBalance: _mntBalance > 0,
              activeIconColor: extendedColors.primaryMain,
              onTap: () => _onOptionTap(isMnt: true),
            ),
            Divider(
              height: 1,
              color: extendedColors.neutral500,
              indent: 24,
              endIndent: 24,
            ),
            // Dollar option
            _buildMethodOption(
              theme: theme,
              extendedColors: extendedColors,
              icon: 'currency-dollar',
              title: l10n.dollar,
              balanceLabel: formatStockAmount(
                _usdBalance,
                isForeign: true,
                decimals: 2,
              ),
              hasBalance: _usdBalance > 0,
              activeIconColor: extendedColors.neutral100,
              onTap: () => _onOptionTap(isMnt: false),
            ),
            Divider(
              height: 1,
              color: extendedColors.neutral500,
              indent: 24,
              endIndent: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption({
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required String icon,
    required String title,
    required String balanceLabel,
    required bool hasBalance,
    required Color activeIconColor,
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    // Үлдэгдэлгүй үед icon бүдэг (цайвар дэвсгэр, бараан тэмдэг) харагдана
    final iconBg = hasBalance ? activeIconColor : extendedColors.bgSecondary;
    final iconColor = hasBalance ? Colors.white : extendedColors.neutral100;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CustomSvgIcon(icon, color: iconColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${l10n.availableAmountLabel}: ',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: extendedColors.neutral200,
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      else
                        Text(
                          balanceLabel,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: extendedColors.neutral100,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CustomSvgIcon(
              'chevron-right',
              color: extendedColors.neutral200,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
