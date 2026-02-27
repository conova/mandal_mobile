import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(theme, l10n.type, type),
        const SizedBox(height: 16),
        _buildDetailRow(theme, l10n.buyQuantity, quantity),
        const SizedBox(height: 16),
        _buildDetailRow(theme, l10n.unitPrice, unitPrice),
        const SizedBox(height: 16),
        _buildDetailRow(theme, '${l10n.commissionLabel} (0.1%)', commission),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalPayment,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            Text(
              total,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
