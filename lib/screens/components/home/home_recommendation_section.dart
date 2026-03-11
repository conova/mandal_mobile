import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class HomeRecommendationSection extends StatefulWidget {
  const HomeRecommendationSection({super.key});

  @override
  State<HomeRecommendationSection> createState() =>
      _HomeRecommendationSectionState();
}

class _HomeRecommendationSectionState extends State<HomeRecommendationSection> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  final List<_RecommendationData> _recommendations = const [
    _RecommendationData(
      title: 'Net Capital',
      subtitle: 'Нэт Капитал',
      status: 'ХААЛТТАЙ',
      duration: '12 сар',
      returnRate: '19.5%',
      amount: '900 сая',
    ),
    _RecommendationData(
      title: 'MIK BOND',
      subtitle: 'Орон сууцны бонд',
      status: 'НЭЭЛТТЭЙ',
      duration: '24 сар',
      returnRate: '11.6%',
      amount: '50 тэрбум',
    ),
    _RecommendationData(
      title: 'Lend.mn',
      subtitle: 'Лэнд.мн',
      status: 'НЭЭЛТТЭЙ',
      duration: '12 сар',
      returnRate: '19.5%',
      amount: '1 тэрбум',
    ),
    _RecommendationData(
      title: 'GSB Capital',
      subtitle: 'ЖИЭСБ капитал',
      status: 'НЭЭЛТТЭЙ',
      duration: '12 сар',
      returnRate: '18.2%',
      amount: '420 сая',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC5D4F8), Color(0xFFDEE6FB)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Purple icon badge
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: extendedColors.purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: extendedColors.bgBase,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.recommendationTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.recommendationDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral300,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // PageView carousel
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _recommendations.length,
              allowImplicitScrolling: true,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final item = _recommendations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildRecommendationCard(
                    context: context,
                    data: item,
                    extendedColors: extendedColors,
                    l10n: l10n,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Page indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_recommendations.length, (index) {
              final isActive = index == _currentPage;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? extendedColors.neutral100
                      : extendedColors.neutral400,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required _RecommendationData data,
    required ExtendedColors extendedColors,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                          data.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: extendedColors.neutral100,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            data.subtitle,
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
                        data.status,
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
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/bond_detail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: extendedColors.purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  l10n.buy,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    'Хугацаа',
                    data.duration,
                    theme,
                    extendedColors,
                  ),
                ),
                VerticalDivider(
                  color: extendedColors.neutral400,
                  thickness: 1,
                  width: 24,
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Өгөөж',
                    data.returnRate,
                    theme,
                    extendedColors,
                  ),
                ),
                VerticalDivider(
                  color: extendedColors.neutral400,
                  thickness: 1,
                  width: 24,
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Дүн',
                    data.amount,
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

class _RecommendationData {
  final String title;
  final String subtitle;
  final String status;
  final String duration;
  final String returnRate;
  final String amount;

  const _RecommendationData({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.duration,
    required this.returnRate,
    required this.amount,
  });
}
