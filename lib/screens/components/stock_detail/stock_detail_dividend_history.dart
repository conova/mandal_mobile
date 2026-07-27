import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:timeline_tile_plus/timeline_tile_plus.dart';
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

    if (items.isEmpty) return const SizedBox.shrink();

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
            children: items.asMap().entries.map((entry) {
              final int idx = entry.key;
              final item = entry.value;
              final bool isFirst = idx == 0;
              final bool isLast = idx == items.length - 1;

              return TimelineTile(
                isFirst: isFirst,
                isLast: isLast,
                alignment: TimelineAlign.manual,
                lineXY: 0.2,
                beforeLineStyle: LineStyle(
                  color: extendedColors.primaryMain,
                  thickness: 1,
                  isDashed: true,
                  dashLength: 4,
                  dashSpacing: 4,
                ),
                afterLineStyle: LineStyle(
                  color: extendedColors.primaryMain,
                  thickness: 1,
                  isDashed: true,
                  dashLength: 4,
                  dashSpacing: 4,
                ),
                indicatorStyle: IndicatorStyle(
                  width: 8,
                  height: 8,
                  indicatorXY: 0.5,
                  indicator: Container(
                    decoration: BoxDecoration(
                      color: extendedColors.primaryMain,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                startChild: Container(
                  padding: const EdgeInsets.only(right: 16, top: 12, bottom: 11),
                  alignment: Alignment.centerRight,
                  child: Text(
                    item['year'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                endChild: Container(
                  padding: const EdgeInsets.only(left: 24, top: 12, bottom: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item['amount'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.primaryMain,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
