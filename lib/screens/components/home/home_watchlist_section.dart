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
                fontSize: 20,
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
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Text(
              l10n.lastPrice24h,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
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
        ),
        _buildWatchlistItem(
          'APU',
          'АПУ ХК',
          '957.01₮',
          '- 0.24%',
          false,
          extendedColors,
        ),
        _buildWatchlistItem(
          'GLMT',
          'Голомт банк',
          '1,124.00₮',
          '0.00%',
          null,
          extendedColors,
        ),
        _buildWatchlistItem(
          'KHAN',
          'Хаан банк',
          '1,343.24₮',
          '- 4.02%',
          false,
          extendedColors,
        ),
        _buildWatchlistItem(
          'LEND',
          'Lend.mn',
          '170.00₮',
          '- 3.43%',
          false,
          extendedColors,
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
              style: TextStyle(
                color: extendedColors.neutral100,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
  ) {
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                name,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: isPositive == null
                      ? Colors.grey
                      : (isPositive
                            ? extendedColors.primaryMain
                            : extendedColors.red),
                  fontSize: 12,
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
