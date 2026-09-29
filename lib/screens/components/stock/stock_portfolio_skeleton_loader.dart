import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class StockPortfolioSkeletonLoader extends StatefulWidget {
  final int itemCount;

  const StockPortfolioSkeletonLoader({
    super.key,
    this.itemCount = 5,
  });

  @override
  State<StockPortfolioSkeletonLoader> createState() => _StockPortfolioSkeletonLoaderState();
}

class _StockPortfolioSkeletonLoaderState extends State<StockPortfolioSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Column(
            children: [
              // Stock Rows
              ...List.generate(
                widget.itemCount,
                (index) => _buildStockRowPlaceholder(extendedColors),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: extendedColors.neutral500),
              const SizedBox(height: 28),
              
              // History Summary
              _buildHistorySummaryPlaceholder(extendedColors),
              const SizedBox(height: 24),
              
              // History Cards
              ...List.generate(
                3,
                (index) => _buildHistoryCardPlaceholder(extendedColors),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockRowPlaceholder(ExtendedColors extendedColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 16,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 70,
                  height: 16,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 14,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 14,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySummaryPlaceholder(ExtendedColors extendedColors) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 140,
          height: 16,
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 180,
          height: 32,
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(width: 80, height: 14, color: extendedColors.bgSecondary),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 16, color: extendedColors.bgSecondary),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: extendedColors.neutral500),
              Expanded(
                child: Column(
                  children: [
                    Container(width: 80, height: 14, color: extendedColors.bgSecondary),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 16, color: extendedColors.bgSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCardPlaceholder(ExtendedColors extendedColors) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 16,
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
