import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class BondConfirmationDetails extends StatelessWidget {
  final String name;
  final String type;
  final String quantity;
  final String unitPrice;
  final String commission;
  final String total;

  const BondConfirmationDetails({
    super.key,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.commission,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(theme, extendedColors, l10n.type, type),
        const SizedBox(height: 16),
        _buildDetailRow(theme, extendedColors, l10n.buyQuantity, quantity),
        const SizedBox(height: 16),
        _buildDetailRow(theme, extendedColors, l10n.unitPrice, unitPrice),
        const SizedBox(height: 16),
        _buildDetailRow(
          theme,
          extendedColors,
          '${l10n.commissionLabel} (0.1%)',
          commission,
        ),
        const SizedBox(height: 24),
        // Dotted divider
        LayoutBuilder(
          builder: (context, constraints) {
            const dashWidth = 4.0;
            const dashSpace = 4.0;
            final dashCount =
                (constraints.maxWidth / (dashWidth + dashSpace)).floor();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: extendedColors.neutral400),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalPayment,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: extendedColors.neutral300,
              ),
            ),
            Text(
              total,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    ExtendedColors extendedColors,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral300,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: extendedColors.neutral100,
          ),
        ),
      ],
    );
  }
}
