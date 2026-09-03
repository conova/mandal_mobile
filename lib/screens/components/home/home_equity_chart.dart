import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/finance_chart.dart';
import '../../../l10n/app_localizations.dart';

class HomeEquityChart extends StatefulWidget {
  const HomeEquityChart({super.key});

  @override
  State<HomeEquityChart> createState() => _HomeEquityChartState();
}

class _HomeEquityChartState extends State<HomeEquityChart> {
  /// Internal state tracks the API period code instead of localized label
  String _selectedPeriod = '1M';
  EquityChart _chart = EquityChart.empty;

  @override
  void initState() {
    super.initState();
    // Background fetch — UI блоклохгүй. Эхний рендер дээр FinanceChart нь
    // sample-spot-уудтай гарч ирэх ба бодит дата ирэнгүүт солигдоно.
    Future.microtask(_fetch);
  }

  /// Сонгосон интервалын эхлэх огноо (дуусах нь өнөөдөр)
  DateTime _startDate() {
    final now = DateTime.now();
    return switch (_selectedPeriod) {
      '1D' => now.subtract(const Duration(days: 1)),
      '1W' => now.subtract(const Duration(days: 7)),
      '1M' => DateTime(now.year, now.month - 1, now.day),
      '3M' => DateTime(now.year, now.month - 3, now.day),
      '1Y' => DateTime(now.year - 1, now.month, now.day),
      _ => DateTime(2000, 1, 1), // ALL
    };
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _fetch() async {
    if (!mounted) return;
    try {
      final auth = context.read<AuthService>();
      // period код биш — start/end огноогоор дуудна
      final chart = await auth.getEquityChart(
        start: _fmt(_startDate()),
        end: _fmt(DateTime.now()),
      );
      if (!mounted) return;
      setState(() => _chart = chart);
    } catch (e) {
      debugPrint('[HomeEquityChart] алдаа: $e');
    }
  }

  void _onFilterTap(String periodCode) {
    if (periodCode == _selectedPeriod) return;
    setState(() => _selectedPeriod = periodCode);
    _fetch();
  }

  /// EquityPoint жагсаалт → FlSpot жагсаалт.
  /// X тэнхлэг: 1 өдөр = 1 нэгж (эхний цэгийн огнооноос хойших хоног) —
  /// огнооны завсар алгассан ч цэгүүд бодит зайгаараа байрлана.
  List<FlSpot> _toSpots(List<EquityPoint> points) {
    if (points.isEmpty) return const [];
    final first = points.first.date;
    return [
      for (final p in points)
        FlSpot(p.date.difference(first).inDays.toDouble(), p.value),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = _toSpots(_chart.points);
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    /// Map localized labels to API period codes
    final Map<String, String> periodMap = {
      l10n.d1: '1D',
      l10n.d7: '1W',
      l10n.m1: '1M',
      l10n.m3: '3M',
      l10n.y1: '1Y',
      l10n.all: 'ALL',
    };

    return Column(
      children: [
        // spots хоосон бол FinanceChart нь sample data-аар (өөрийн default)
        // дүүргэгдэх — UI шууд харагдана.
        FinanceChart(
          spots: spots.isEmpty ? null : spots,
          height: 100,
          startDate:
              _chart.points.isEmpty ? null : _chart.points.first.date,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: periodMap.entries
              .map((entry) => _timeFilter(theme, entry.key, entry.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _timeFilter(ThemeData theme, String label, String periodCode) {
    final extendedColors = theme.extension<ExtendedColors>()!;
    final isSelected = _selectedPeriod == periodCode;
    return GestureDetector(
      onTap: () => _onFilterTap(periodCode),
      child: Text(
        label,
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
