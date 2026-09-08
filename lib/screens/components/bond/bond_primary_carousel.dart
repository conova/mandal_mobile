import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';

class BondPrimaryCarousel extends StatefulWidget {
  final List<MarketInstrument> bonds;

  const BondPrimaryCarousel({
    super.key,
    required this.bonds,
  });

  @override
  State<BondPrimaryCarousel> createState() => _BondPrimaryCarouselState();
}

class _BondPrimaryCarouselState extends State<BondPrimaryCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    if (widget.bonds.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            itemCount: widget.bonds.length,
            itemBuilder: (context, idx) {
              final bond = widget.bonds[idx];
              final progress = orderProgress(bond.orderedAmt, bond.amt) ?? 0.0;

              final orderEndDate = parseStockDate(bond.orderEndDate);
              final dynamic term = (bond.market == 'Primary' && orderEndDate != null)
                  ? orderEndDate
                  : (bond.term.isEmpty
                      ? '-'
                      : (num.tryParse(bond.term) != null
                          ? '${bond.term} ${l10n.monthLabel}'
                          : bond.term));

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bond.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: extendedColors.neutral100,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    bond.subtitle,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: extendedColors.neutral300,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Row(
                          children: [
                            Text(
                              formatIntRate(bond.intRate).replaceAll('%', ''),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: extendedColors.neutral100,
                              ),
                            ),
                            Text(
                              '% ${l10n.interestRate.toLowerCase()}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.normal,
                                color: extendedColors.neutral100,
                              ),
                            ),
                            const SizedBox(width: 24),
                            _buildTermDisplay(term, theme, extendedColors, l10n),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: CustomButton(
                          label: l10n.placeOrder,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/bond_detail',
                            arguments: {
                              'bond': bond.raw,
                              'languageCode': Localizations.localeOf(context).languageCode,
                            },
                          ),
                          variant: CustomButtonVariant.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (widget.bonds.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.bonds.length,
              (idx) => Container(
                width: _currentIndex == idx ? 24 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: _currentIndex == idx
                      ? extendedColors.neutral100
                      : extendedColors.neutral500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTermDisplay(dynamic term, ThemeData theme, ExtendedColors extendedColors, AppLocalizations l10n) {
    if (term is DateTime) {
      final text = formatTimeLeftCompact(term, l10n);
      final parts = text.split(' ');
      if (parts.length >= 2) {
        return Row(
          children: [
            Text(
              parts[0],
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
            Text(
              ' ${parts.sublist(1).join(' ')}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.normal,
                color: extendedColors.neutral100,
              ),
            ),
          ],
        );
      }
      return Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: extendedColors.neutral100,
        ),
      );
    }

    return Text(
      term.toString(),
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: extendedColors.neutral100,
      ),
    );
  }
}
