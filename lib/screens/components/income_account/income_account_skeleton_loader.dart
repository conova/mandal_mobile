import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class IncomeAccountSkeletonLoader extends StatefulWidget {
  final int itemCount;

  const IncomeAccountSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  @override
  State<IncomeAccountSkeletonLoader> createState() => _IncomeAccountSkeletonLoaderState();
}

class _IncomeAccountSkeletonLoaderState extends State<IncomeAccountSkeletonLoader>
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primary account placeholder
              _buildAccountCardPlaceholder(extendedColors, isPrimary: true),
              const SizedBox(height: 16),
              
              // Text prompt placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              // "Other accounts" title placeholder
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              
              // Other accounts list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.itemCount,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildAccountCardPlaceholder(extendedColors),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountCardPlaceholder(ExtendedColors extendedColors, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? Border.all(color: extendedColors.primary100.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account number placeholder
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                // Bank name placeholder
                Container(
                  width: 180,
                  height: 18,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Chevron placeholder
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
