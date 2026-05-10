import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
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
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/add_watchlist');
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: extendedColors.primaryMain,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.white, size: 20),
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral200,
              ),
            ),
            Text(
              l10n.lastPrice24h,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral200,
              ),
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
          child: CustomButton(
            onPressed: () {
              Navigator.pushNamed(context, '/watchlist_detail');
            },
            label: '${l10n.viewAll} (12)',
            variant: CustomButtonVariant.tertiary,
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  change,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isPositive == null
                        ? extendedColors.neutral200
                        : (isPositive
                              ? extendedColors.primaryMain
                              : extendedColors.red),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
