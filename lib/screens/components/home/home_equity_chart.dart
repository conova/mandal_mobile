import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/finance_chart.dart';

class HomeEquityChart extends StatefulWidget {
  const HomeEquityChart({super.key});

  @override
  State<HomeEquityChart> createState() => _HomeEquityChartState();
}

class _HomeEquityChartState extends State<HomeEquityChart> {
  /// Шошго (UI) → API period код
  static const Map<String, String> _periodMap = {
    '1Х': '1D',
    '7Х': '1W',
    '1С': '1M',
    '3С': '3M',
    '1Ж': '1Y',
    'Бүгд': 'ALL',
  };

  String _selectedFilter = '1С';
  EquityChart _chart = EquityChart.empty;

  @override
  void initState() {
    super.initState();
    // Background fetch — UI блоклохгүй. Эхний рендер дээр FinanceChart нь
    // sample-spot-уудтай гарч ирэх ба бодит дата ирэнгүүт солигдоно.
    Future.microtask(_fetch);
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    try {
      final auth = context.read<AuthService>();
      final period = _periodMap[_selectedFilter] ?? '1Y';
      final chart = await auth.getEquityChart(period: period);
      if (!mounted) return;
      setState(() => _chart = chart);
    } catch (e) {
      debugPrint('[HomeEquityChart] алдаа: $e');
    }
  }

  void _onFilterTap(String f) {
    if (f == _selectedFilter) return;
    setState(() => _selectedFilter = f);
    _fetch();
  }

  /// EquityPoint жагсаалт → FlSpot жагсаалт (X тэнхлэг нь index, Y нь value)
  List<FlSpot> _toSpots(List<EquityPoint> points) {
    return [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = _toSpots(_chart.points);

    return Column(
      children: [
        // spots хоосон бол FinanceChart нь sample data-аар (өөрийн default)
        // дүүргэгдэх — UI шууд харагдана.
        FinanceChart(spots: spots.isEmpty ? null : spots, height: 100),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _periodMap.keys
              .map((label) => _timeFilter(theme, label))
              .toList(),
        ),
      ],
    );
  }

  Widget _timeFilter(ThemeData theme, String text) {
    final extendedColors = theme.extension<ExtendedColors>()!;
    final isSelected = _selectedFilter == text;
    return GestureDetector(
      onTap: () => _onFilterTap(text),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: isSelected
              ? extendedColors.neutral100
              : extendedColors.neutral300,
        ),
      ),
    );
  }
}
