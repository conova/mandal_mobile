import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';

/// Цэнэглэх данс сонгох — Хувьцаа/Бонд (₮) болон Доллар данснууд.
class IncomeMethodScreen extends StatefulWidget {
  const IncomeMethodScreen({super.key});

  @override
  State<IncomeMethodScreen> createState() => _IncomeMethodScreenState();
}

class _IncomeMethodScreenState extends State<IncomeMethodScreen> {
  /// Боломжит үлдэгдэл — /portfolio/breakdown-ийн mnt/usd мөрөөс.
  /// TODO: хувьцаа/бондын дансны тусдаа үлдэгдлийн API холбогдмогц салгана
  double _mntBalance = 0;
  double _usdBalance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchBalances);
  }

  Future<void> _fetchBalances() async {
    try {
      final breakdown = await context.read<AuthService>().getAssetBreakdown();
      final summary = await context.read<AuthService>().getPortfolioSummary();
      if (!mounted) return;
      double byType(String type) {
        final row = breakdown.firstWhere(
          (b) => b['type']?.toString() == type,
          orElse: () => const {},
        );
        return (row['amount'] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        _mntBalance = byType('mnt') - summary.holdAmount;
        _usdBalance = byType('usd');
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.depositSelectTitle,
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
                  l10n.depositSelectSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // ₮ данснууд
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
                title: l10n.buyStock,
                balanceLabel: l10n.availableBalanceLabel,
                balance: formatStockAmount(_mntBalance, decimals: 0),
                isLoading: _isLoading,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/income_amount',
                  arguments: 'mnt',
                ),
              ),
              Divider(height: 1, color: extendedColors.neutral500),
              AccountTypeRow(
                icon: 'tugrug-01',
                iconBg: extendedColors.primaryMain,
                iconColor: Colors.white,
                title: l10n.buyBond,
                balanceLabel: l10n.availableBalanceLabel,
                balance: formatStockAmount(_mntBalance, decimals: 0),
                isLoading: _isLoading,
                onTap: () => Navigator.pushNamed(context, '/deposit_info'),
              ),
              Divider(height: 1, color: extendedColors.neutral500),
              const SizedBox(height: 28),
              // $ данснууд
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
                onTap: () => Navigator.pushNamed(
                  context,
                  '/income_amount',
                  arguments: 'usd',
                ),
              ),
              Divider(height: 1, color: extendedColors.neutral500),
            ],
          ),
        ),
      ),
    );
  }
}

/// Данс сонгох мөр — icon, гарчиг, "Боломжит үлдэгдэл: X" (teal), chevron.
/// income_method болон withdraw_method хоёуланд ашиглагдана.
class AccountTypeRow extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String balanceLabel;
  final String balance;
  final bool isLoading;
  final VoidCallback onTap;

  const AccountTypeRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.balanceLabel,
    required this.balance,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

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
              child: Center(child: CustomSvgIcon(icon, color: iconColor)),
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
                        '$balanceLabel: ',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: extendedColors.neutral200,
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      else
                        Text(
                          balance,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: extendedColors.primaryMain,
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
