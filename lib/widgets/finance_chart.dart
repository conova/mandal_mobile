import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinanceChart extends StatelessWidget {
  const FinanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: 6,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5),
                FlSpot(5, 3), FlSpot(6, 4), FlSpot(7, 3), FlSpot(8, 4), FlSpot(9, 3),
                FlSpot(10, 5), FlSpot(11, 5),
              ],
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
