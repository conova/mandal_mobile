import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class BondBuySkeletonLoader extends StatefulWidget {
  const BondBuySkeletonLoader({super.key});

  @override
  State<BondBuySkeletonLoader> createState() => _BondBuySkeletonLoaderState();
}

class _BondBuySkeletonLoaderState extends State<BondBuySkeletonLoader>
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
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 60, top: 24),
            children: [
              // Primary Market Section Title Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: extendedColors.bgBase,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Primary Market Carousel Placeholder (Detailed card)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPrimaryCardPlaceholder(extendedColors),
              ),
              const SizedBox(height: 32),

              // Secondary Market Section Title Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 140,
                      height: 18,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 32,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 70,
                      height: 32,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 80,
                      height: 32,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Secondary Market List Placeholders
              ...List.generate(4, (index) => _buildCompactCardPlaceholder(extendedColors)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrimaryCardPlaceholder(ExtendedColors extendedColors) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 20,
                        decoration: BoxDecoration(
                          color: extendedColors.bgBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 140,
                        height: 14,
                        decoration: BoxDecoration(
                          color: extendedColors.bgBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: extendedColors.bgBase,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: extendedColors.bgBase,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: extendedColors.bgBase,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: extendedColors.bgBase,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCardPlaceholder(ExtendedColors extendedColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(18),
         ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: extendedColors.bgBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: extendedColors.bgBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              height: 24,
              decoration: BoxDecoration(
                color: extendedColors.bgBase,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 63,
              height: 40,
              decoration: BoxDecoration(
                color: extendedColors.bgBase,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
