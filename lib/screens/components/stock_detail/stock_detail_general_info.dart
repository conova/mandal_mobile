import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/custom_info_popup_bottom_sheet.dart';
import '../../../widgets/custom_svg_icon.dart';

class StockDetailGeneralInfo extends StatelessWidget {
  final String marketCap;
  final String avgVolume;
  final String peRatio;
  final String pbRatio;
  final String dailyVolume;
  final String dividendYield;

  const StockDetailGeneralInfo({
    super.key,
    this.marketCap = '-',
    this.avgVolume = '-',
    this.peRatio = '-',
    this.pbRatio = '-',
    this.dailyVolume = '-',
    this.dividendYield = '-',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.generalInfo,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  l10n.marketCap,
                  marketCap,
                  theme,
                  extendedColors,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  l10n.avgVolume,
                  avgVolume,
                  theme,
                  extendedColors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Price-to-Earnings ratio',
                  peRatio,
                  theme,
                  extendedColors,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Price-to-Book ratio',
                  pbRatio,
                  theme,
                  extendedColors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMetricRowWithInfo(
            l10n.dailyVolume,
            dailyVolume,
            l10n.dividendYield,
            dividendYield,
            theme,
            extendedColors,
            l10n
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: extendedColors.neutral200,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: extendedColors.neutral100,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRowWithInfo(
    String label1,
    String value1,
    String label2,
    String value2,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(label1, value1, theme, extendedColors),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: extendedColors.neutral200,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value2,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(width: 4),
                  CustomInfoPopupBottomSheet(
                    title: dividendYield,
                    description: 'None',
                    extendedColors: extendedColors,
                    l10n: l10n,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
