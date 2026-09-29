import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class BondPortfolioSkeletonLoader extends StatefulWidget {
  final int itemCount;

  const BondPortfolioSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  @override
  State<BondPortfolioSkeletonLoader> createState() => _BondPortfolioSkeletonLoaderState();
}

class _BondPortfolioSkeletonLoaderState extends State<BondPortfolioSkeletonLoader>
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
            children: List.generate(
              widget.itemCount,
              (index) => _buildBondRowPlaceholder(extendedColors),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBondRowPlaceholder(ExtendedColors extendedColors) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: extendedColors.neutral500)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 20,
                            decoration: BoxDecoration(
                              color: extendedColors.bgSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 60,
                            height: 16,
                            decoration: BoxDecoration(
                              color: extendedColors.bgSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: extendedColors.bgSecondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 90,
                      height: 20,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 130,
                      height: 16,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            width: double.infinity,
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: extendedColors.bgSecondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
