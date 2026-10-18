import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';

class BondPaymentDetails extends StatelessWidget {
  final String totalPayment;
  /// Өгөөжийн утга — дүн эсвэл хувиар (дуудагчаас хамаарна)
  final String yieldValue;

  /// YTM rate (жишээ нь "14.32%") — өгөөжийн дүнгийн хажууд харагдана
  final String? yieldRate;
  final VoidCallback onDetailsPressed;

  const BondPaymentDetails({
    super.key,
    required this.totalPayment,
    required this.yieldValue,
    this.yieldRate,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return GestureDetector(
      onTap: onDetailsPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalPayment,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.yield,
                  style: theme.textTheme.bodyMedium?.copyWith(color: extendedColors.neutral200),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalPayment,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20,),
                  // Дүн урт үед ч YTM хувь тасрахгүй — дүн нь л "…" болно
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          yieldValue,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: extendedColors.neutral100,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (yieldRate != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '($yieldRate)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: AppTextStyles.light,
                            color: extendedColors.primaryMain,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ]
              )
            ),
            Column(
              children: [
                const SizedBox(height: 4,),
                CustomSvgIcon(
                  'chevron-right',
                  color: extendedColors.neutral100,
                  size: 24,
                ),
              ],
            )
          ]
        ),
      ),
    );
  }
}