import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class StockSkeletonLoader extends StatefulWidget {
  final int itemCount;
  final bool isGrid;

  const StockSkeletonLoader({
    super.key,
    this.itemCount = 9,
    this.isGrid = true,
  });

  @override
  State<StockSkeletonLoader> createState() => _StockSkeletonLoaderState();
}

class _StockSkeletonLoaderState extends State<StockSkeletonLoader>
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
          child: widget.isGrid
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: widget.itemCount,
                  itemBuilder: (context, index) => _buildStockTilePlaceholder(extendedColors),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.itemCount,
                  itemBuilder: (context, index) => _buildStockTilePlaceholder(extendedColors),
                ),
        );
      },
    );
  }

  Widget _buildStockTilePlaceholder(ExtendedColors extendedColors) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 14,
                decoration: BoxDecoration(
                  color: extendedColors.bgBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 30,
                height: 12,
                decoration: BoxDecoration(
                  color: extendedColors.bgBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: extendedColors.bgBase,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: extendedColors.bgBase,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          Container(
            width: 50,
            height: 16,
            decoration: BoxDecoration(
              color: extendedColors.bgBase,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
