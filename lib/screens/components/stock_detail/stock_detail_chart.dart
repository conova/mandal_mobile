import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

class StockDetailChart extends StatelessWidget {
  const StockDetailChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomPaint(
            painter: _ChartPainter(
              lineColor: extendedColors.primaryMain,
              areaColor: extendedColors.primaryMain.withOpacity(0.1),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPeriodSelector(theme, extendedColors),
      ],
    );
  }

  Widget _buildPeriodSelector(ThemeData theme, ExtendedColors extendedColors) {
    final periods = ['1X', '7X', '1C', '3C', '1Ж', 'Бүгд'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: periods.map((p) {
          bool isSelected = p == '1X';
          return TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: isSelected
                  ? Colors.transparent
                  : Colors.transparent,
            ),
            child: Text(
              p,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.3),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color lineColor;
  final Color areaColor;

  _ChartPainter({required this.lineColor, required this.areaColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.1, size.height * 0.65);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.85);
    path.lineTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.45);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.35);
    path.lineTo(size.width * 0.9, size.height * 0.55);
    path.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path, paint);

    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final areaPaint = Paint()
      ..color = areaColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
