import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// График — `spots` өгөгдсөн бол түүгээр зурна, үгүй бол default sample.
/// minY/maxY автоматаар [spots]-ийн дотроос тооцоологдоно (padding 5% нэмж).
class FinanceChart extends StatelessWidget {
  final List<FlSpot>? spots;

  const FinanceChart({super.key, this.spots});

  static const List<FlSpot> _sampleSpots = [
    FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5),
    FlSpot(5, 3), FlSpot(6, 4), FlSpot(7, 3), FlSpot(8, 4), FlSpot(9, 3),
    FlSpot(10, 5), FlSpot(11, 5),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useSpots = (spots != null && spots!.isNotEmpty) ? spots! : _sampleSpots;

    // Y тэнхлэгийн хязгаар — point-уудаас тооцоолно
    double minY = useSpots.first.y;
    double maxY = useSpots.first.y;
    double minX = useSpots.first.x;
    double maxX = useSpots.first.x;
    for (final s in useSpots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
      if (s.x < minX) minX = s.x;
      if (s.x > maxX) maxX = s.x;
    }
    final yPad = (maxY - minY).abs() * 0.1;
    if (yPad == 0) {
      // Бүх утга тэнцүү — visual нь хавтгай шугам байх ёстой
      minY -= 1;
      maxY += 1;
    } else {
      minY -= yPad;
      maxY += yPad;
    }
    if (maxX == minX) maxX = minX + 1;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: useSpots,
              isCurved: true,
              color: theme.primaryColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.primaryColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
