import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'order_detail_summary_item.dart';

class OrderDetailHistory extends StatelessWidget {
  const OrderDetailHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.executionHistory,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildHistoryItem(
          '2025.11.5 10:00',
          '10,010,000₮',
          '100,100₮',
          '10 ${l10n.quantityLabel.toLowerCase()}',
          theme,
          l10n,
        ),
        _buildHistoryItem(
          '2025.11.4 18:00',
          '6,000,000₮',
          '100,000₮',
          '6 ${l10n.quantityLabel.toLowerCase()}',
          theme,
          l10n,
        ),
        _buildHistoryItem(
          '2025.11.3 22:21',
          '5,000,000₮',
          '100,000₮',
          '5 ${l10n.quantityLabel.toLowerCase()}',
          theme,
          l10n,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    String date,
    String amount,
    String price,
    String qty,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          OrderDetailSummaryItem(label: l10n.tradeAmount, value: amount),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.unitPrice,
                  value: price,
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.executedQuantity,
                  value: qty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }
}
