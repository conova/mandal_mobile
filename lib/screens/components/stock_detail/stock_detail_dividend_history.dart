import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';

class StockDetailDividendHistory extends StatelessWidget {
  const StockDetailDividendHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final history = [
      {'year': '2024', 'amount': '5,000,000.12₮'},
      {'year': '2023', 'amount': '4,900,000.12₮'},
      {'year': '2022', 'amount': '4,800,000.34₮'},
      {'year': '2021', 'amount': '4,500,000.54₮'},
      {'year': '2020', 'amount': '4,200,000.91₮'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pastDividends,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: history.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        item['year']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: extendedColors.primaryMain,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (idx != history.length - 1)
                          Expanded(
                            child: Container(
                              width: 1,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: extendedColors.primaryMain.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        item['amount']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.primaryMain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
