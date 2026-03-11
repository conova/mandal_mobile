import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../widgets/asset_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class HomeAssetBreakdown extends StatelessWidget {
  const HomeAssetBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assetBreakdown,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: AppTextStyles.semiBold,
          ),
        ),
        const SizedBox(height: 16),
        AssetCard(
          icon: Icons.currency_ruble,
          title: l10n.tugrik,
          subtitle: l10n.orderCount('2'),
          amount: '128,000.53₮',
          onTap: () => Navigator.pushNamed(context, '/currency_detail', arguments: 'mnt'),
        ),
        AssetCard(
          icon: Icons.attach_money,
          title: l10n.dollar,
          subtitle: l10n.orderCount('0'),
          amount: '0.00\$',
          isDark: true,
          onTap: () => Navigator.pushNamed(context, '/currency_detail', arguments: 'usd'),
        ),
        AssetCard(
          icon: Icons.credit_card,
          title: l10n.bonds,
          subtitle: '5 ${l10n.type}',
          amount: '50,000,000.00₮',
          iconColor: extendedColors.purple,
          onTap: () => Navigator.pushNamed(context, '/bond_portfolio'),
        ),
        AssetCard(
          icon: Icons.pie_chart_outline,
          title: l10n.stocks,
          subtitle: '3 ${l10n.type}',
          amount: '500,000.00₮',
          iconColor: extendedColors.orange,
          onTap: () => Navigator.pushNamed(context, '/stock_portfolio'),
        ),
      ],
    );
  }
}
