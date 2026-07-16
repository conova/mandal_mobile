import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Захиалгын самбарын нэг мөр (авах эсвэл зарах тал)
class OrderBookEntry {
  final double price;
  final int quantity;

  const OrderBookEntry({required this.price, required this.quantity});
}

/// Захиалгын самбар — /stocks/order_book-ийн BUY/SELL мөрүүдийг зэрэгцүүлж
/// харуулна. Талбар бүрийн дэвсгэрийн дүүргэлт нь тухайн талын хамгийн их
/// ширхэгт харьцуулсан хэмжээ.
class StockTradingOrderBoard extends StatelessWidget {
  final List<OrderBookEntry> buyOrders;
  final List<OrderBookEntry> sellOrders;

  const StockTradingOrderBoard({
    super.key,
    this.buyOrders = const [],
    this.sellOrders = const [],
  });

  /// /stocks/order_book-ийн түүхий мөрүүдээс угсарна:
  /// ORDER_TYPE-аар хувааж PRICE_RANK-аар эрэмбэлнэ.
  factory StockTradingOrderBoard.fromApi(
    List<Map<String, dynamic>> rows, {
    Key? key,
  }) {
    List<OrderBookEntry> parse(String type) {
      final filtered =
          rows
              .where((r) => r['ORDER_TYPE']?.toString().toUpperCase() == type)
              .toList()
            ..sort((a, b) {
              final ra = int.tryParse(a['PRICE_RANK']?.toString() ?? '') ?? 0;
              final rb = int.tryParse(b['PRICE_RANK']?.toString() ?? '') ?? 0;
              return ra.compareTo(rb);
            });
      return filtered
          .map(
            (r) => OrderBookEntry(
              price: double.tryParse(r['PRICE']?.toString() ?? '') ?? 0,
              quantity: int.tryParse(r['TOTAL_CNT']?.toString() ?? '') ?? 0,
            ),
          )
          .toList();
    }

    return StockTradingOrderBoard(
      key: key,
      buyOrders: parse('BUY'),
      sellOrders: parse('SELL'),
    );
  }

  /// Үнийг мянгачилж форматлана: 1000100.12 → "1,000,100.12₮"
  String _formatPrice(double price) {
    final str = price % 1 == 0
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    final dotIdx = str.indexOf('.');
    final wholePart = dotIdx == -1 ? str : str.substring(0, dotIdx);
    final whole = wholePart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final formatted = dotIdx == -1 ? whole : '$whole${str.substring(dotIdx)}';
    return '$formatted₮';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final rowCount = max(buyOrders.length, sellOrders.length);
    // Дүүргэлтийн харьцааг талын хамгийн их ширхэгт харьцуулж бодно
    final maxBuyQty = buyOrders.fold<int>(1, (m, e) => max(m, e.quantity));
    final maxSellQty = sellOrders.fold<int>(1, (m, e) => max(m, e.quantity));

    return Column(
      children: [
        // Толгой — бүтэн өргөнтэй саарал pill, "Авах"/"Зарах" голд ойрхон
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.buyTab,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.sellTab,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (rowCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              l10n.noData,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral300,
              ),
            ),
          )
        else
          for (var i = 0; i < rowCount; i++)
            _buildOrderDepthRow(
              buy: i < buyOrders.length ? buyOrders[i] : null,
              sell: i < sellOrders.length ? sellOrders[i] : null,
              maxBuyQty: maxBuyQty,
              maxSellQty: maxSellQty,
              extendedColors: extendedColors,
              theme: theme,
            ),
      ],
    );
  }

  Widget _buildOrderDepthRow({
    required OrderBookEntry? buy,
    required OrderBookEntry? sell,
    required int maxBuyQty,
    required int maxSellQty,
    required ExtendedColors extendedColors,
    required ThemeData theme,
  }) {
    const rowHeight = 41.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: rowHeight,
        child: Row(
          children: [
            // Авах тал — bar голоос ЗҮҮН тийш сунана
            Expanded(
              child: buy == null
                  ? const SizedBox()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth =
                            (constraints.maxWidth * (buy.quantity / maxBuyQty))
                                .clamp(8.0, constraints.maxWidth);
                        return Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: barWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: extendedColors.primary100,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            // Ширхэг — зүүн захад
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  buy.quantity.toString(),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: extendedColors.neutral100,
                                  ),
                                ),
                              ),
                            ),
                            // Үнэ — голд ойрхон (баруун зах)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  _formatPrice(buy.price),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: extendedColors.neutral100,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(width: 4),
            // Зарах тал — bar голоос БАРУУН тийш сунана
            Expanded(
              child: sell == null
                  ? const SizedBox()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth =
                            (constraints.maxWidth *
                                    (sell.quantity / maxSellQty))
                                .clamp(8.0, constraints.maxWidth);
                        return Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: barWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: extendedColors.red.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    topLeft: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            // Үнэ — голд ойрхон (зүүн зах)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  _formatPrice(sell.price),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: extendedColors.red,
                                  ),
                                ),
                              ),
                            ),
                            // Ширхэг — баруун захад
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  sell.quantity.toString(),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: extendedColors.neutral100,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
