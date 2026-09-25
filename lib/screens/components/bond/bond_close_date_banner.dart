import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';

/// "Бонд хаагдах төлөвлөгөөт огноо" — улбар шар анхааруулах хайрцаг.
/// Анхдагч болон гадаад бондын дизайн хуваалцана.
class BondCloseDateBanner extends StatelessWidget {
  final DateTime date;

  const BondCloseDateBanner({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: extendedColors.orange200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomSvgIcon(
            'annotation-info',
            color: extendedColors.orange,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bondClosePlannedDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: AppTextStyles.regular,
                  ),
                ),
                Text(
                  formatStockDate(date).replaceAll('/', '.'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
