import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/custom_svg_icon.dart';
import '../../../widgets/stock_price_row.dart';

/// Home дэлгэцийн "Санал болгох хувьцаа" хэсэг —
/// /stocks/nbo-ийн STOCKGRP == 'stock' мөрүүдийг carousel-аар харуулна.
class HomeStockRecommendationSection extends StatefulWidget {
  const HomeStockRecommendationSection({super.key});

  @override
  State<HomeStockRecommendationSection> createState() =>
      _HomeStockRecommendationSectionState();
}

class _HomeStockRecommendationSectionState
    extends State<HomeStockRecommendationSection> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  bool _isLoading = true;
  List<MarketInstrument> _stocks = const [];

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
        // Санал болголт тул эхний 10-аар хязгаарлана — үгүй бол carousel-ийн
        // цэгэн индикатор дэлгэцэд багтахгүй (олон зуун хувьцаа ирдэг)
        _stocks = rows
            .where((r) => r['STOCKGRP']?.toString() == 'stock')
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

    // Мэдээлэл байхгүй бол хэсгийг бүхэлд нь нуана
    if (!_isLoading && _stocks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Гадна давхарга — градиент border (1px)
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [extendedColors.orange300, extendedColors.orange200],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [extendedColors.orange200, extendedColors.orange100],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Orange icon badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: extendedColors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const CustomSvgIcon(
                'coins-swap-02',
                color: AppColors.bgBase,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.stockRecommendationTitle,
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
                l10n.stockRecommendationDesc,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w200,
                  color: extendedColors.neutral100,
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
                      itemCount: _stocks.length,
                      allowImplicitScrolling: true,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final item = _stocks[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                          child: _buildStockCard(item, extendedColors),
                        );
                      },
                    ),
            ),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_stocks.length, (index) {
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(MarketInstrument data, ExtendedColors extendedColors) {
    final change = data.priceChange;
    final price = data.closePrice == null
        ? '-'
        : formatStockAmount(data.closePrice, decimals: 0);
    final changeStr = change == null
        ? '-'
        : '${change.abs().toStringAsFixed(2)}%';
    final bool? isGrowing = change == null || change == 0 ? null : change > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.circular(16),
        // 0px 8px 16px #FF794029
        boxShadow: [
          BoxShadow(
            color: extendedColors.orange.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: StockPriceRow(
        symbol: data.symbol,
        name: data.name,
        price: price,
        change: changeStr,
        isGrowing: isGrowing,
        onTap: () => Navigator.pushNamed(
          context,
          '/stock_detail',
          arguments: {
            'symbol': data.symbol,
            'name': data.name,
            'price': price,
            'change': changeStr,
            'isGrowing': isGrowing,
            'stockcode': data.stockcode,
          },
        ),
      ),
    );
  }
}
