import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class HomeStockRecommendationSkeletonLoader extends StatefulWidget {
  const HomeStockRecommendationSkeletonLoader({super.key});

  @override
  State<HomeStockRecommendationSkeletonLoader> createState() =>
      _HomeStockRecommendationSkeletonLoaderState();
}

class _HomeStockRecommendationSkeletonLoaderState
    extends State<HomeStockRecommendationSkeletonLoader>
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
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [extendedColors.orange300, extendedColors.orange200],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [extendedColors.orange200, extendedColors.orange100],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Icon placeholder
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: extendedColors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title placeholder
                  Container(
                    width: 200,
                    height: 24,
                    decoration: BoxDecoration(
                      color: extendedColors.bgBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description placeholder
                  Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: extendedColors.bgBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Card placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 86,
                      margin: const EdgeInsets.only(bottom: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: extendedColors.bgBase,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: extendedColors.bgSecondary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 120,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: extendedColors.bgSecondary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
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
                                width: 40,
                                height: 12,
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
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
