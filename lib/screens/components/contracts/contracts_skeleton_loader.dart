import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class ContractsSkeletonLoader extends StatefulWidget {
  final int itemCount;

  const ContractsSkeletonLoader({
    super.key,
    this.itemCount = 4,
  });

  @override
  State<ContractsSkeletonLoader> createState() => _ContractsSkeletonLoaderState();
}

class _ContractsSkeletonLoaderState extends State<ContractsSkeletonLoader>
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.itemCount,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: extendedColors.neutral500),
            itemBuilder: (context, index) => _buildContractRowPlaceholder(extendedColors),
          ),
        );
      },
    );
  }

  Widget _buildContractRowPlaceholder(ExtendedColors extendedColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 24),
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
