import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/finance_chart.dart';
import '../../../l10n/app_localizations.dart';

/// Сонгосон интервалын өөрчлөлт — HomeAssetSummary-гийн дүн/хувь/шошго
/// чартын period-ийг дагаж шинэчлэгдэхэд ашиглана.
class EquityPeriodInfo {
  final String periodCode; // '1D' | '1W' | '1M' | '3M' | '1Y' | 'ALL'
  final double change;
  final double percent;

  const EquityPeriodInfo({
    required this.periodCode,
    required this.change,
    required this.percent,
  });
}

/// Daily running balance (one entry per calendar day)
class _DailyBalance {
  final DateTime date;
  final double balance;
  const _DailyBalance(this.date, this.balance);
}

class HomeEquityChart extends StatefulWidget {
  /// Period солигдож дата ирэх бүрд интервалын өөрчлөлтийг нийтэлнэ
  final ValueNotifier<EquityPeriodInfo?>? infoNotifier;

  const HomeEquityChart({super.key, this.infoNotifier});

  @override
  State<HomeEquityChart> createState() => _HomeEquityChartState();
}

class _HomeEquityChartState extends State<HomeEquityChart> {
  /// Internal state tracks the API period code instead of localized label
  String _selectedPeriod = '1M';
  EquityChart _chart = EquityChart.empty;

  /// Continuous daily balances derived from _chart.points
  List<_DailyBalance> _daily = const [];

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
      final end = DateTime.now();
      // period код биш — start/end огноогоор дуудна
      final chart = await auth.getEquityChart(
        start: _fmt(_startDate()),
        end: _fmt(end),
      );
      if (!mounted) return;
      setState(() {
        _chart = chart;
        _daily = _buildDailyBalances(chart.points, end);
      });
      _publishPeriodInfo();
    } catch (e) {
      debugPrint('[HomeEquityChart] алдаа: $e');
    }
  }

  /// points: first item = beginning balance, the rest = change on that date.
  /// Returns one balance per day from the first date to [end]; days with no
  /// change keep the previous balance.
  List<_DailyBalance> _buildDailyBalances(
      List<EquityPoint> points,
      DateTime end,
      ) {
    if (points.isEmpty) return const [];

    DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    // Sum changes per day (handles several entries on the same date)
    final changes = <DateTime, double>{};
    for (final p in points) {
      final d = dayOnly(p.date);
      changes[d] = (changes[d] ?? 0) + p.value;
    }

    final start = dayOnly(points.first.date);
    var last = dayOnly(end);
    // Make sure we never cut off data later than "end"
    final lastPointDay = dayOnly(points.last.date);
    if (lastPointDay.isAfter(last)) last = lastPointDay;

    final totalDays = last.difference(start).inDays;
    final result = <_DailyBalance>[];
    var balance = 0.0;

    for (var i = 0; i <= totalDays; i++) {
      // Constructing from y/m/d avoids DST issues of adding Durations
      final d = DateTime(start.year, start.month, start.day + i);
      balance += changes[d] ?? 0; // day 0 = beginning balance
      result.add(_DailyBalance(d, balance));
    }
    return result;
  }

  /// Интервалын эхний/сүүлийн өдрийн үлдэгдлээс өөрчлөлтийг тооцож дээрх
  /// нийт хөрөнгийн хэсэгт мэдэгдэнэ
  void _publishPeriodInfo() {
    final notifier = widget.infoNotifier;
    if (notifier == null) return;
    if (_daily.length < 2) {
      notifier.value = EquityPeriodInfo(
        periodCode: _selectedPeriod,
        change: 0,
        percent: 0,
      );
      return;
    }
    final first = _daily.first.balance;
    final last = _daily.last.balance;
    final change = last - first;
    notifier.value = EquityPeriodInfo(
      periodCode: _selectedPeriod,
      change: change,
      percent: first != 0 ? change / first * 100 : 0,
    );
  }

  void _onFilterTap(String periodCode) {
    if (periodCode == _selectedPeriod) return;
    setState(() => _selectedPeriod = periodCode);
    _fetch();
  }

  /// Daily balances → FlSpot list.
  /// X axis: index of day since the first date (1 day = 1 unit)
  List<FlSpot> _toSpots() {
    return [
      for (var i = 0; i < _daily.length; i++)
        FlSpot(i.toDouble(), _daily[i].balance),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = _toSpots();
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
          height: 180,
          startDate: _daily.isEmpty ? null : _daily.first.date,
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