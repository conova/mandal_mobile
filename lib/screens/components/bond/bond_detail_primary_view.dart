import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/circle_back_button.dart';
import 'bond_circular_progress.dart';
import 'bond_close_date_banner.dart';
import 'bond_fact_card.dart';

/// АНХДАГЧ зах зээлийн бондын дизайн: дүүргэлтийн дугуй индикатор,
/// цугларсан/зорилтот дүн, хаагдах төлөвлөгөөт огноо, үзүүлэлтүүдийн
/// карт болон танилцуулга үзэх товч.
class BondDetailPrimaryView extends StatelessWidget {
  final MarketInstrument? bond;

  const BondDetailPrimaryView({super.key, required this.bond});

  /// Хувь хүний бондын хүүгийн татвар — API-аас ирээгүй бол 10%
  static const String _defaultTaxRate = '10%';

  /// Хугацаа — тоо бол "12 сар", огноо бол өөрөө нь
  String _termLabel(AppLocalizations l10n) {
    final term = bond?.term ?? '';
    if (term.isEmpty) return '-';
    return num.tryParse(term) != null ? '$term ${l10n.monthLabel}' : term;
  }

  /// Хүү төлөх давтамж — locale-ийн дагуу (хоосон бол нөгөөгөөр нөхнө)
  String _payPeriodOf(BuildContext context) {
    final mn = bond?.payPeriod ?? '';
    final en = bond?.payPeriod2 ?? '';
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final value =
    isEnglish ? (en.isNotEmpty ? en : mn) : (mn.isNotEmpty ? mn : en);
    return value.isEmpty ? '-' : value;
  }

  /// Татварын хувь — raw-д TAX талбар ирвэл түүгээр
  String get _taxLabel {
    final raw = bond?.raw['TAX'] ?? bond?.raw['TAXRATE'];
    final value = num.tryParse(raw?.toString() ?? '');
    return value == null ? _defaultTaxRate : '$value%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;

    final isForeign = bond?.isForeign ?? false;
    final progress = orderProgress(bond?.orderedAmt, bond?.amt) ?? 0;
    // Захиалга хаагдах огноо — анхдагч зах зээлд бонд хаагдах өдөр
    final closeDate = parseStockDate(bond?.orderEndDate);
    final languageCode = Localizations.localeOf(context).languageCode;

    final hasSubtitle = (bond?.subtitle ?? '').isNotEmpty;
    final circleSize = screenWidth * 0.45;
    // dots.png хэр хол доош үргэлжлэх вэ: header + завсар + дугуй.
    final headerApproxHeight =
        topInset + 20 + 40 + 8 + 28 + (hasSubtitle ? 20 : 0);
    final backgroundHeight = headerApproxHeight + 16 + circleSize + 16;

    return Stack(
      children: [
        // Header болон түүний доор орших BondCircularProgress хоёрын
        // ард нэг дэвсгэр зураг байрлана.
        Positioned(
          top: 0,
          left: screenWidth * 0.3,
          right: 0,
          height: backgroundHeight,
          child: Opacity(
            opacity: 0.2,
            child: Transform.scale(
              scale: 0.8, // smaller pattern — tweak as needed
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/images/dots.png',
                fit: BoxFit.cover,
                alignment: Alignment.topRight,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    bond?.name ?? '',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  if (hasSubtitle)
                    Text(
                      bond!.subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTextStyles.light,
                        color: extendedColors.neutral200,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BondCircularProgress(
                    percentage: progress,
                    label: l10n.fillRate,
                    size: circleSize,
                  ),
                  const SizedBox(height: 16),
                  // Цугларсан / Зорилтот дүн
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _AmountStat(
                            label: l10n.collectedAmount,
                            value: formatStockAmount(
                              bond?.orderedAmt ?? 0,
                              isForeign: isForeign,
                              decimals: 0,
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: extendedColors.neutral500,
                        ),
                        Expanded(
                          child: _AmountStat(
                            label: '${l10n.targetAmount}:',
                            value: formatCompactAmount(
                              (bond?.cnt ?? 0) * (bond?.stockPrice ?? 0),
                              languageCode: languageCode,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (closeDate != null) ...[
                    BondCloseDateBanner(date: closeDate),
                    const SizedBox(height: 24),
                  ],
                  // Үзүүлэлтүүд + танилцуулга үзэх товч нэг картад
                  BondFactCard(
                    facts: [
                      BondFact(l10n.term, _termLabel(l10n)),
                      BondFact(
                          l10n.annualInterest, formatIntRate(bond?.intRate)),
                      BondFact(l10n.paymentFrequency, _payPeriodOf(context)),
                      BondFact(l10n.taxLabel, _taxLabel),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Цугларсан / Зорилтот дүнгийн багана
class _AmountStat extends StatelessWidget {
  final String label;
  final String value;

  const _AmountStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: AppTextStyles.light,
            color: extendedColors.neutral200,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppTextStyles.semiBold,
              color: extendedColors.neutral100,
            ),
          ),
        ),
      ],
    );
  }
}