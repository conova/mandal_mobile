import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class StockDetailGeneralInfo extends StatelessWidget {
  const StockDetailGeneralInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.generalInfo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  l10n.marketCap,
                  '₮800 ${l10n.billion}',
                  theme,
                ),
              ),
              Expanded(
                child: _buildMetricItem(l10n.avgVolume, '₮340,000', theme),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Price-to-Earnings ratio',
                  '1.5',
                  theme,
                ),
              ),
              Expanded(
                child: _buildMetricItem('Price-to-Book ratio', '1.5', theme),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMetricRowWithInfo(
            l10n.dailyVolume,
            '₮100,000',
            l10n.dividendYield,
            '10%',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
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
  ) {
    return Row(
      children: [
        Expanded(child: _buildMetricItem(label1, value1, theme)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value2,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
