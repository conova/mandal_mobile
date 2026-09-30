import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class SummaryReportSkeletonLoader extends StatefulWidget {
  const SummaryReportSkeletonLoader({super.key});

  @override
  State<SummaryReportSkeletonLoader> createState() => _SummaryReportSkeletonLoaderState();
}

class _SummaryReportSkeletonLoaderState extends State<SummaryReportSkeletonLoader>
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Assets Label Placeholder
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Total Amount Placeholder
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Container(
                      width: 150,
                      height: 32,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Change info row placeholder
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Chart Placeholder
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),
                // Time Filters Placeholder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: 40,
                      height: 14,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Asset Table Placeholder
                Container(
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => _buildRowPlaceholder(extendedColors, index % 2 == 0),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Divider(height: 1, color: extendedColors.neutral500),
                const SizedBox(height: 36),
                // Cash Flow Section Placeholder
                Container(
                  child: Column(
                    children: List.generate(
                      4,
                      (index) => _buildRowPlaceholder(extendedColors, index % 2 == 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRowPlaceholder(ExtendedColors extendedColors, bool isOdd) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOdd ? extendedColors.bgSecondary : Colors.transparent,
        borderRadius: isOdd ? BorderRadius.circular(12) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: isOdd ? extendedColors.bgBase : extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Row(
            children: [
              Container(
                width: 70,
                height: 14,
                decoration: BoxDecoration(
                  color: isOdd ? extendedColors.bgBase : extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 70,
                height: 14,
                decoration: BoxDecoration(
                  color: isOdd ? extendedColors.bgBase : extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
