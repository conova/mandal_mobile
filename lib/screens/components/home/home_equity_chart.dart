import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
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

  Future<void> _fetch() async {
    if (!mounted) return;
    try {
      final auth = context.read<AuthService>();
      final chart = await auth.getEquityChart(period: _selectedPeriod);
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
        FinanceChart(spots: spots.isEmpty ? null : spots, height: 100),
        const SizedBox(height: 10),
        CustomSvgIcon('meter', size: screenWidth * 0.15,),
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
