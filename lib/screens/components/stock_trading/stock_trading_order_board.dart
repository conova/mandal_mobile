import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order_book_entry.dart';
import '../../../widgets/custom_svg_icon.dart';

class StockTradingOrderBoard extends StatefulWidget {
  final List<OrderBookEntry> buyOrders;
  final List<OrderBookEntry> sellOrders;
  final double? marketPrice;

  const StockTradingOrderBoard({
    super.key,
    this.buyOrders = const [],
    this.sellOrders = const [],
    this.marketPrice,
  });

  @override
  State<StockTradingOrderBoard> createState() => _StockTradingOrderBoardState();
}

class _StockTradingOrderBoardState extends State<StockTradingOrderBoard> {
  bool _isExpanded = false;

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(2);
    final parts = str.split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$whole.${parts[1]}₮';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    // 1. Highest Buy & Lowest Sell
    final highestBuy = widget.buyOrders.isNotEmpty
        ? widget.buyOrders.map((e) => e.price).reduce(max)
        : null;
    final lowestSell = widget.sellOrders.isNotEmpty
        ? widget.sellOrders.map((e) => e.price).reduce(min)
        : null;

    // Max quantity calculations for depth bars relative size
    final maxBuyQty = widget.buyOrders.fold<int>(1, (m, e) => max(m, e.quantity));
    final maxSellQty = widget.sellOrders.fold<int>(1, (m, e) => max(m, e.quantity));

    // Sort: Sell orders descending (top to bottom down to market price), Buy orders descending from market price down
    final sortedSellOrders = List<OrderBookEntry>.from(widget.sellOrders)
      ..sort((a, b) => b.price.compareTo(a.price));

    final sortedBuyOrders = List<OrderBookEntry>.from(widget.buyOrders)
      ..sort((a, b) => b.price.compareTo(a.price));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Text(
                l10n.orderBoard,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
              const SizedBox(height: 16),

              // Summary Cards Box
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: l10n.highestBuyPrice,
                      price: highestBuy != null ? _formatPrice(highestBuy) : '-',
                      bgColor: extendedColors.primary100,
                      textColor: extendedColors.primaryMain,
                      extendedColors: extendedColors,
                      theme: theme,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      leftAlign: true,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildSummaryCard(
                      title: l10n.lowestSellPrice,
                      price: lowestSell != null ? _formatPrice(lowestSell) : '-',
                      bgColor: extendedColors.red.withValues(alpha: 0.1),
                      textColor: extendedColors.red,
                      extendedColors: extendedColors,
                      theme: theme,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      leftAlign: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Expanded Order Book View
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                // 1. Sell Orders List (Red Bars - Right Side)
                if (sortedSellOrders.isEmpty)
                  _buildEmptyState(theme, extendedColors, l10n)
                else
                  for (final order in sortedSellOrders)
                    _buildSellRow(
                      entry: order,
                      maxQty: maxSellQty,
                      extendedColors: extendedColors,
                      theme: theme,
                    ),

                // 2. Market Price Separator Divider
                if (widget.marketPrice != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: extendedColors.bgSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${l10n.marketPrice}: ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral200,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            _formatPrice(widget.marketPrice!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral100,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // 3. Buy Orders List (Green/Primary Bars - Left Side)
                if (sortedBuyOrders.isEmpty)
                  _buildEmptyState(theme, extendedColors, l10n)
                else
                  for (final order in sortedBuyOrders)
                    _buildBuyRow(
                      entry: order,
                      maxQty: maxBuyQty,
                      extendedColors: extendedColors,
                      theme: theme,
                    ),

                const SizedBox(height: 16),
              ],

              // Toggle Expand/Collapse Button
              Center(
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? l10n.collapse : l10n.details,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: extendedColors.neutral100,
                          ),
                        ),
                        const SizedBox(width: 4),
                        CustomSvgIcon(
                          _isExpanded
                              ? 'chevron-up'
                              : 'chevron-down',
                          color: extendedColors.neutral200,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: extendedColors.neutral500,)
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String price,
    required Color bgColor,
    required Color textColor,
    required ExtendedColors extendedColors,
    required ThemeData theme,
    required BorderRadius borderRadius,
    required bool leftAlign
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: leftAlign ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: extendedColors.neutral200,
              height: 1.3,
            ),
            textAlign: leftAlign ? TextAlign.start : TextAlign.end,
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Sell Row (Price on center-left, Bar starts after GAP, Quantity follows right end of bar)
  Widget _buildSellRow({
    required OrderBookEntry entry,
    required int maxQty,
    required ExtendedColors extendedColors,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Empty left side alignment spacer
          const Expanded(child: SizedBox()),

          // Center-Left: Price Column
          SizedBox(
            width: 80,
            child: Text(
              _formatPrice(entry.price),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: extendedColors.neutral100,
              ),
            ),
          ),

          // GAP between Center Price Column and Graph Bar
          const SizedBox(width: 16),

          // Right Side: Graph Bar + Quantity following right end
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Reserve max 60px space for quantity text
                final maxBarSpace = constraints.maxWidth - 60;
                final barWidth =
                (maxBarSpace * (entry.quantity / maxQty)).clamp(12.0, maxBarSpace);

                return Row(
                  children: [
                    Container(
                      height: 18,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: extendedColors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          entry.quantity.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: FontWeight.w500,
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
    );
  }

  /// Buy Row (Quantity on left end of bar, Bar extends right, GAP, Price on center-right)
  Widget _buildBuyRow({
    required OrderBookEntry entry,
    required int maxQty,
    required ExtendedColors extendedColors,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Left Side: Quantity text following left end + Graph Bar
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Reserve max 60px space for quantity text
                final maxBarSpace = constraints.maxWidth - 60;
                final barWidth =
                (maxBarSpace * (entry.quantity / maxQty)).clamp(12.0, maxBarSpace);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 50,
                      child: FittedBox(
                        alignment: Alignment.centerRight,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          entry.quantity.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 18,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: extendedColors.primaryMain,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // GAP between Graph Bar and Center Price Column
          const SizedBox(width: 16),

          // Center-Right: Price Column
          SizedBox(
            width: 80,
            child: Text(
              _formatPrice(entry.price),
              textAlign: TextAlign.left,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: extendedColors.neutral100,
              ),
            ),
          ),

          // Empty right side alignment spacer
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      ThemeData theme,
      ExtendedColors extendedColors,
      AppLocalizations l10n,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          l10n.noData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral300,
          ),
        ),
      ),
    );
  }
}