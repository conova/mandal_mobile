import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class OrderSkeletonLoader extends StatefulWidget {
  final int itemCount;

  const OrderSkeletonLoader({
    super.key,
    this.itemCount = 4,
  });

  @override
  State<OrderSkeletonLoader> createState() => _OrderSkeletonLoaderState();
}

class _OrderSkeletonLoaderState extends State<OrderSkeletonLoader>
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.itemCount,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerTheme.color ?? extendedColors.neutral500,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Amount row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 16,
                              decoration: BoxDecoration(
                                color: extendedColors.bgSecondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 12,
                              decoration: BoxDecoration(
                                color: extendedColors.bgSecondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
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
                    const SizedBox(height: 8),
                    // Badges row
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            color: extendedColors.bgSecondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 50,
                          height: 20,
                          decoration: BoxDecoration(
                            color: extendedColors.bgSecondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 45,
                          height: 20,
                          decoration: BoxDecoration(
                            color: extendedColors.bgSecondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Info rows
                    _buildInfoRowPlaceholder(extendedColors),
                    const SizedBox(height: 8),
                    _buildInfoRowPlaceholder(extendedColors),
                    const SizedBox(height: 8),
                    _buildInfoRowPlaceholder(extendedColors),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRowPlaceholder(ExtendedColors extendedColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 100,
          height: 12,
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
