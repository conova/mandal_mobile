import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class HomeWatchlistSection extends StatelessWidget {
  const HomeWatchlistSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.watchlist,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: extendedColors.neutral100.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: extendedColors.neutral100,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.stocks,
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
            ),
            Text(
              l10n.lastPrice24h,
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWatchlistItem(
          'AARD',
          'Ард капитал',
          '3,299.02₮',
          '+ 9.71%',
          true,
          extendedColors,
          context,
        ),
        _buildWatchlistItem(
          'APU',
          'АПУ ХК',
          '957.01₮',
          '- 0.24%',
          false,
          extendedColors,
          context,
        ),
        _buildWatchlistItem(
          'GLMT',
          'Голомт банк',
          '1,124.00₮',
          '0.00%',
          null,
          extendedColors,
          context,
        ),
        _buildWatchlistItem(
          'KHAN',
          'Хаан банк',
          '1,343.24₮',
          '- 4.02%',
          false,
          extendedColors,
          context,
        ),
        _buildWatchlistItem(
          'LEND',
          'Lend.mn',
          '170.00₮',
          '- 3.43%',
          false,
          extendedColors,
          context,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: extendedColors.bgSecondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '${l10n.viewAll} (12)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchlistItem(
    String symbol,
    String name,
    String price,
    String change,
    bool? isPositive,
    ExtendedColors extendedColors,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                name,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                change,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isPositive == null
                      ? Colors.grey
                      : (isPositive
                            ? extendedColors.primaryMain
                            : extendedColors.red),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
