import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';

/// Шошго дээр, огноо доор нь — бондын гол огноонуудыг жагсаахад.
/// Хоёрдогч болон гадаад бондын дизайн хуваалцана.
class BondDateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isLast;

  const BondDateRow({
    super.key,
    required this.label,
    this.date,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTextStyles.light,
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date == null ? '-' : formatStockDate(date!).replaceAll('/', '.'),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: AppTextStyles.regular,
              color: extendedColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }
}
