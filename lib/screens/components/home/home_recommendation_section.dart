import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class HomeRecommendationSection extends StatelessWidget {
  const HomeRecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recommendationTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.recommendationDesc,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRecommendationCard(
                context,
                l10n.mandalBond,
                'Net Capital бонд',
                'БОНД ТАНЫ ИРЭЭДҮЙН ТӨЛӨӨ',
                '19.5%',
                extendedColors.primaryMain,
                extendedColors,
                l10n,
              ),
              const SizedBox(width: 16),
              _buildRecommendationCard(
                context,
                'MIK BOND',
                'МИК Орон сууцны бонд',
                'ЭРСДЭЛ БАГА ХӨРӨНГӨ ОРУУЛАЛТ',
                '11.6%',
                extendedColors.purple,
                extendedColors,
                l10n,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    String tag,
    String title,
    String subtitle,
    String rate,
    Color iconColor,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: extendedColors.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Icon(Icons.bookmark_border, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.annualInterest,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  Text(
                    rate,
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/bond_detail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: extendedColors.purple,
                  foregroundColor: extendedColors.bgBase,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15.5,
                  ),
                ),
                child: Text(
                  l10n.buy,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
