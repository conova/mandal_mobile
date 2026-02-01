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
        _buildDetailRow(l10n.type, type),
        const SizedBox(height: 16),
        _buildDetailRow(l10n.buyQuantity, quantity),
        const SizedBox(height: 16),
        _buildDetailRow(l10n.unitPrice, unitPrice),
        const SizedBox(height: 16),
        _buildDetailRow('${l10n.commissionLabel} (0.1%)', commission),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalPayment,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            Text(
              total,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ],
    );
  }
}
