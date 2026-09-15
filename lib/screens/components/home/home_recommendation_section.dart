import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_snackbar.dart';

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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
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

    // Гадна давхарга — градиент border (1px)
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [extendedColors.purple300, extendedColors.purple200],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [extendedColors.purple200, extendedColors.purple100],
          ),
          borderRadius: BorderRadius.circular(15),
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
              child: CustomSvgIcon(
                'bank-note-01',
                size: 32,
                color: AppColors.bgBase,
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
                  color: extendedColors.neutral100,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // PageView carousel
            SizedBox(
              height: 112,
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
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 22),
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
            // Page indicator dots
            if (_recommendations.isNotEmpty && _recommendations.length != 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_recommendations.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    // Идэвхтэй үед сунасан pill, бусад нь жижиг дугуй
                    width: isActive ? 24 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isActive
                          ? extendedColors.neutral100
                          : extendedColors.neutral400,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  /// Мокапын авсаархан карт: зүүнд нэр + хугацаа, баруунд өгөөж болон
  /// "Авах" товч.
  Widget _buildRecommendationCard({
    required BuildContext context,
    required MarketInstrument data,
    required ExtendedColors extendedColors,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);

    final endDt = parseStockDate(data.endDate);
    final orderEndDate = parseStockDate(data.orderEndDate);

    // Prioritize DateTime objects for the tenure display to enable "X left" format.
    final dynamic tenure = (data.market == 'Secondary' && endDt != null)
        ? endDt
        : (data.market == 'Primary' && orderEndDate != null)
            ? orderEndDate
            : (data.term.isEmpty
                ? '-'
                : (num.tryParse(data.term) != null
                    ? '${data.term} ${l10n.monthLabel}'
                    : data.term));

    String tenureStr = '-';
    if (tenure is DateTime) {
      tenureStr = formatTimeLeft(tenure, l10n);
    } else if (tenure != null) {
      tenureStr = tenure.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.circular(16),
        // 0px 8px 16px #3D57DA29
        boxShadow: [
          BoxShadow(
            color: extendedColors.purple.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tenureStr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatIntRate(data.intRate),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.purple,
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
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            ),
            child: Text(
              l10n.buy,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppTextStyles.bold,
                color: extendedColors.bgBase,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
