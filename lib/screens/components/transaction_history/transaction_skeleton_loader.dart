import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class TransactionSkeletonLoader extends StatefulWidget {
  final int itemCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const TransactionSkeletonLoader({
    super.key,
    this.itemCount = 6,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<TransactionSkeletonLoader> createState() => _TransactionSkeletonLoaderState();
}

class _TransactionSkeletonLoaderState extends State<TransactionSkeletonLoader>
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
          child: ListView.builder(
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics ?? const NeverScrollableScrollPhysics(),
            itemCount: widget.itemCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    // Icon placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Date placeholders
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            width: 100,
                            height: 12,
                            decoration: BoxDecoration(
                              color: extendedColors.bgSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Amount placeholder
                    Container(
                      width: 70,
                      height: 16,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
