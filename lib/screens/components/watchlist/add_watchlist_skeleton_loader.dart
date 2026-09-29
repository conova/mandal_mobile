import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class AddWatchlistSkeletonLoader extends StatefulWidget {
  final int itemCount;

  const AddWatchlistSkeletonLoader({
    super.key,
    this.itemCount = 20,
  });

  @override
  State<AddWatchlistSkeletonLoader> createState() => _AddWatchlistSkeletonLoaderState();
}

class _AddWatchlistSkeletonLoaderState extends State<AddWatchlistSkeletonLoader>
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
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: widget.itemCount,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: extendedColors.neutral500,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 16,
                            decoration: BoxDecoration(
                              color: extendedColors.bgSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 140,
                            height: 12,
                            decoration: BoxDecoration(
                              color: extendedColors.bgSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        shape: BoxShape.circle,
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
