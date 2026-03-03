import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class HomeRecommendationSection extends StatelessWidget {
  const HomeRecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC5D4F8), Color(0xFFDEE6FB)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: extendedColors.purple, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: extendedColors.purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.currency_ruble,
              color: extendedColors.bgBase,
              size: 32,
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              textAlign: TextAlign.center,
              l10n.recommendationTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              textAlign: TextAlign.center,
              l10n.recommendationDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildRecommendationCard(
                  context: context,
                  title: 'Net Capital',
                  subtitle: 'Нэт Капитал',
                  status: 'ХААЛТТАЙ',
                  durationValue: '12 сар',
                  returnValue: '19.5%',
                  amountValue: '900 сая',
                  extendedColors: extendedColors,
                  l10n: l10n,
                ),
                const SizedBox(width: 16),
                _buildRecommendationCard(
                  context: context,
                  title: 'MIK BOND',
                  subtitle: 'Орон сууцны бонд',
                  status: 'НЭЭЛТТЭЙ',
                  durationValue: '24 сар',
                  returnValue: '11.6%',
                  amountValue: '50 тэрбум',
                  extendedColors: extendedColors,
                  l10n: l10n,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String status,
    required String durationValue,
    required String returnValue,
    required String amountValue,
    required ExtendedColors extendedColors,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 330,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: extendedColors.neutral100,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: extendedColors.neutral100,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CustomButton(
                label: l10n.buy,
                size: CustomButtonSize.small,
                onPressed: () => Navigator.pushNamed(context, '/bond_detail'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    'Хугацаа',
                    durationValue,
                    theme,
                    extendedColors,
                  ),
                ),
                VerticalDivider(
                  color: extendedColors.neutral200,
                  thickness: 1,
                  width: 24,
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Өгөөж',
                    returnValue,
                    theme,
                    extendedColors,
                  ),
                ),
                VerticalDivider(
                  color: extendedColors.neutral200,
                  thickness: 1,
                  width: 24,
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Дүн',
                    amountValue,
                    theme,
                    extendedColors,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: extendedColors.neutral300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
