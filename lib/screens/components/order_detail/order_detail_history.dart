import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order.dart';
import '../../../theme/extended_colors.dart';
import 'order_detail_summary_item.dart';

/// Захиалгын биелэлтийн түүх — API мөр бүр нэг биелэлтийг илэрхийлдэг
/// тул тухайн захиалгын done мэдээллийг харуулна.
class OrderDetailHistory extends StatelessWidget {
  final Order order;
  const OrderDetailHistory({super.key, required this.order});

  /// "2025/04/28 20:53:03" → "2025.04.28 20:53"
  String _fmtDate(String raw) {
    if (raw.isEmpty) return '-';
    final parts = raw.split(' ');
    final date = parts.first.replaceAll('/', '.');
    final time =
        parts.length > 1 ? parts[1].split(':').take(2).join(':') : '';
    return time.isEmpty ? date : '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final isForeign = order.isForeignCurrency;
    final doneCnt = order.doneCnt ?? 0;
    final doneAmount = doneCnt * (order.donePrice ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.executionHistory,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildHistoryItem(
          _fmtDate(order.doneDate),
          formatStockAmount(doneAmount, isForeign: isForeign),
          formatStockAmount(order.donePrice, isForeign: isForeign),
          '${formatStockAmount(doneCnt, decimals: 0).replaceAll('₮', '')} '
              '${l10n.quantityLabel.toLowerCase()}',
          theme,
          l10n,
          extendedColors,
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
    ExtendedColors extendedColors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
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
          Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
        ],
      ),
    );
  }
}
