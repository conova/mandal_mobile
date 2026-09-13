import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';

/// Анхдагч зах зээлийн бондын дүүргэлтийг харуулах дугуй индикатор —
/// голдоо хувь болон "Дүүргэлт" бичигтэй.
class BondCircularProgress extends StatelessWidget {
  /// 0.0 .. 1.0
  final double percentage;
  final String label;
  final double size;

  const BondCircularProgress({
    super.key,
    required this.percentage,
    required this.label,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final value = percentage.clamp(0.0, 1.0);

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: value,
            trackColor: extendedColors.bgTertiary,
            progressColor: extendedColors.primaryMain,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).round()}%',
                  style: AppTextStyles.display.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.value,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height)
        .deflate(strokeWidth / 2);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    if (value <= 0) return;

    final progress = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 12 цагийн байрлалаас цагийн зүүний дагуу
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
