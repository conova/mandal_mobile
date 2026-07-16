import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';

class StockDetailDividendHistory extends StatelessWidget {
  /// Ногдол ашгийн түүх: [{year, amount}] — хоосон бол хэсэг нуугдана
  final List<Map<String, String>> items;

  const StockDetailDividendHistory({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final history = items;
    if (history.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pastDividends,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
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
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                        right: 24,
                        top: 0,
                      ),
                      child: Text(
                        item['year']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: extendedColors.neutral100,
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
                              color: extendedColors.primaryMain,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        item['amount']!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.primaryMain,
                          fontWeight: FontWeight.w300,
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
