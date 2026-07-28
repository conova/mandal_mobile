import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order.dart';
import 'order_detail_summary_item.dart';

class OrderDetailSummary extends StatelessWidget {
  final Order order;
  const OrderDetailSummary({super.key, required this.order});

  /// "2025/04/30 00:00:00" → "2025.04.30" (хоосон бол '-')
  String _dateOnly(String raw) {
    if (raw.isEmpty) return '-';
    return raw.split(' ').first.replaceAll('/', '.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    final isForeign = order.isForeignCurrency;
    final yieldRaw = order.raw['YIELD']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderDetailSummaryItem(
            label: l10n.tradeAmount,
            value: formatStockAmount(order.totalAmount, isForeign: isForeign),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.unitPrice,
                  value: formatStockAmount(order.price, isForeign: isForeign),
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.executionQuantity.split('/')[0],
                  value: order.executionLabel,
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
                  value: order.orderNameOf(lang),
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.orderStatusLabel,
                  value: order.statusNameOf(lang),
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
                  value: yieldRaw.isEmpty ? '-' : '$yieldRaw%',
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.settlementDate,
                  value: _dateOnly(order.settleDate),
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
                  value: order.orderDateLabel,
                ),
              ),
              Expanded(
                child: OrderDetailSummaryItem(
                  label: l10n.commissionLabel,
                  value: order.feeAmount == null
                      ? '-'
                      : formatStockAmount(
                          order.feeAmount,
                          isForeign: isForeign,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
