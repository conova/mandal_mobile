import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'order_detail_summary_item.dart';

class OrderDetailSummary extends StatelessWidget {
  const OrderDetailSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderDetailSummaryItem(label: l10n.tradeAmount, value: '42,042,000₮'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.unitPrice,
                  value: '100,000₮',
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.executionQuantity.split('/')[0],
                  value: '21/42 (50%)',
                  valueColor: extendedColors.primaryMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.orderTypeLabel,
                  value: l10n.limitPrice,
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.orderStatusLabel,
                  value: l10n.partiallyFilled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.yieldLabel,
                  value: '18.0%',
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.settlementDate,
                  value: '2025.06.04',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.orderDate,
                  value: '2025.11.3 17:22',
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.commissionLabel,
                  value: '₮1,000',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
