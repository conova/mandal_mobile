import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/section_title.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/stock_row_format.dart';
import '../../../models/market_instrument.dart';

class IpoCarousel extends StatefulWidget {
  final List<MarketInstrument> ipoStocks;
  final Function(MarketInstrument) onStockTap;

  const IpoCarousel({
    super.key,
    required this.ipoStocks,
    required this.onStockTap,
  });

  @override
  State<IpoCarousel> createState() => _IpoCarouselState();
}

class _IpoCarouselState extends State<IpoCarousel> {
  late PageController _ipoPageController;
  int _ipoPage = 0;

  @override
  void initState() {
    super.initState();
    _ipoPageController = PageController(
      viewportFraction: widget.ipoStocks.length < 2 ? 1.0 : 0.85,
    );
  }

  @override
  void didUpdateWidget(covariant IpoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ipoStocks.length != widget.ipoStocks.length) {
      _ipoPageController.dispose();
      _ipoPageController = PageController(
        viewportFraction: widget.ipoStocks.length < 2 ? 1.0 : 0.85,
      );
    }
  }

  @override
  void dispose() {
    _ipoPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ipoStocks.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final onlyPrimary = widget.ipoStocks.length < 2;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(l10n.ipo, true, true),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    l10n.ipoSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral100,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _ipoPageController,
              itemCount: widget.ipoStocks.length,
              onPageChanged: (i) => setState(() => _ipoPage = i),
              itemBuilder: (context, i) =>
                  _buildIpoCard(widget.ipoStocks[i], l10n, theme, extendedColors, onlyPrimary),
            ),
          ),
          if (widget.ipoStocks.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.ipoStocks.length, (i) {
                final active = i == _ipoPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? extendedColors.neutral100
                        : extendedColors.neutral400,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIpoCard(
    MarketInstrument row,
    AppLocalizations l10n,
    ThemeData theme,
    ExtendedColors extendedColors,
    bool onlyPrimary,
  ) {
    final progress = orderProgress(row.orderedAmt, row.amt) ?? 0.0;
    final price = row.stockPrice == null
        ? (row.closePrice == null
            ? '-'
            : formatStockAmount(row.closePrice, decimals: 2))
        : formatStockAmount(row.stockPrice, decimals: 2);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: onlyPrimary ? 16 : 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          row.companyName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: extendedColors.neutral200,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 4,
                          color: extendedColors.neutral500,
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          color: extendedColors.primaryMain,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.unitStockPrice,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: extendedColors.neutral200,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          price,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1.5, height: 36, color: extendedColors.neutral500),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.term,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: extendedColors.neutral200,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _ipoPeriod(row),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: l10n.placeOrder,
              size: CustomButtonSize.medium,
              onPressed: () => widget.onStockTap(row),
            ),
          ],
        ),
      ),
    );
  }

  String _ipoPeriod(MarketInstrument row) {
    String fmt(dynamic raw) {
      final d = parseStockDate(raw);
      if (d == null) return '';
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(d.month)}/${two(d.day)}';
    }

    final sFmt = fmt(row.orderBeginDate);
    final eFmt = fmt(row.orderEndDate);

    if (sFmt.isEmpty && eFmt.isEmpty) return '-';
    if (sFmt.isNotEmpty && eFmt.isNotEmpty) return '$sFmt – $eFmt';
    return sFmt.isNotEmpty ? sFmt : eFmt;
  }
}
