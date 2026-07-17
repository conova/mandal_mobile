import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/stock_row_format.dart';
import '../../../models/market_instrument.dart';
import '../../../services/auth_service.dart';
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

  bool _isLoading = true;
  List<MarketInstrument> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchNbo);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchNbo() async {
    try {
      final auth = context.read<AuthService>();
      final rows = await auth.getNboStocks();
      if (!mounted) return;
      setState(() {
        // Энэ хэсэгт зөвхөн бонд харуулна; хувьцааг
        // HomeStockRecommendationSection харуулна. Цэгэн индикатор
        // дэлгэцэд багтахаар эхний 10-аар хязгаарлана.
        _recommendations = rows
            .where((r) => r['STOCKGRP']?.toString() == 'bond')
            .take(10)
            .map(MarketInstrument.fromJson)
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    // Мэдээлэл байхгүй бол хэсгийг бүхэлд нь нууна
    if (!_isLoading && _recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

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
            child: CustomSvgIcon('bank-note-01', size: 32, color: AppColors.bgBase,),
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: FontWeight.w200,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // PageView carousel
          SizedBox(
            height: 200,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
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


  /// Хугацааг locale-ийн дагуу нэгжтэй харуулна:
  ///   12 → "12 сар" (мон) / "12 month" (англи); огноо бол шууд
  String _formatDuration(MarketInstrument data, String languageCode) {
    final term = data.term;
    if (term.isEmpty) return '-';
    if (num.tryParse(term) == null) return term;
    return languageCode == 'en' ? '$term month' : '$term сар';
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required MarketInstrument data,
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // Контент өндөр/өргөнөөс хэтэрвэл бүхэлдээ жижигрэх тул
                  // текстүүд ямар ч үед нэг мөрөнд багтана (overflow гарахгүй)
                  child: LayoutBuilder(
                    builder: (context, constraints) => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: constraints.maxWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: extendedColors.neutral100,
                              ),
                            ),
                            if (data.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                data.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: extendedColors.neutral300,
                                ),
                              ),
                            ],
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
                                data.isOpen ? 'Нээлттэй' : 'Хаалттай',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: extendedColors.neutral100,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/bond_detail',
                    arguments: data.raw,
                  ),
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
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    'Хугацаа',
                    _formatDuration(
                      data,
                      Localizations.localeOf(context).languageCode,
                    ),
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
                    data.intRate == null ? '-' : '${data.intRate}%',
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
                    data.amt == null
                        ? '-'
                        : formatCompactAmount(
                            data.amt,
                            languageCode:
                                Localizations.localeOf(context).languageCode,
                          ),
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: theme.textTheme.labelMedium?.copyWith(
              color: extendedColors.neutral300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
