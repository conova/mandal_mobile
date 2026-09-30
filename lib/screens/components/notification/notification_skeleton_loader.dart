import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class NotificationSkeletonLoader extends StatefulWidget {
  final int itemCount;

  const NotificationSkeletonLoader({
    super.key,
    this.itemCount = 8,
  });

  @override
  State<NotificationSkeletonLoader> createState() => _NotificationSkeletonLoaderState();
}

class _NotificationSkeletonLoaderState extends State<NotificationSkeletonLoader>
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
            itemBuilder: (context, index) => _buildNotificationItemPlaceholder(extendedColors),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItemPlaceholder(ExtendedColors extendedColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: extendedColors.neutral500, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Placeholder
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Placeholder
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle Line 1 Placeholder
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle Line 2 Placeholder
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                // Time Placeholder
                Container(
                  width: 60,
                  height: 10,
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
}
