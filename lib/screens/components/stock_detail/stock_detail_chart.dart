import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/stock_row_format.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/finance_chart.dart';

/// Stock chart — `/stocks/{SYMBOL}/chart` API-аас өгөгдөл татаж зурна.
/// `symbol` дамжуулаагүй бол placeholder зурна (хуучин зан хадгална).
class StockDetailChart extends StatefulWidget {
  final String? symbol;
  const StockDetailChart({super.key, this.symbol});

  @override
  State<StockDetailChart> createState() => _StockDetailChartState();
}

enum _Period { d1, d7, m1, m3, y1, all }

class _StockDetailChartState extends State<StockDetailChart> {
  _Period _selected = _Period.d1;
  List<FlSpot> _spots = const [];

  /// Эхний цэгийн огноо — tooltip дээр өдрийн огноо харуулахад
  DateTime? _startDate;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.symbol != null && widget.symbol!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
    }
  }

  (DateTime, DateTime) _periodRange() {
    final now = DateTime.now();
    return switch (_selected) {
      _Period.d1 => (now.subtract(const Duration(days: 1)), now),
      _Period.d7 => (now.subtract(const Duration(days: 7)), now),
      _Period.m1 => (DateTime(now.year, now.month - 1, now.day), now),
      _Period.m3 => (DateTime(now.year, now.month - 3, now.day), now),
      _Period.y1 => (DateTime(now.year - 1, now.month, now.day), now),
      _Period.all => (DateTime(2000, 1, 1), now),
    };
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _fetch() async {
    final sym = widget.symbol;
    if (sym == null || sym.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final (start, end) = _periodRange();
      final auth = context.read<AuthService>();
      final data = await auth.getStockChart(sym, start: _fmt(start), end: _fmt(end));

      // Хариунаас огноо + үнийг задална. X тэнхлэг: 1 өдөр = 1 нэгж
      // (эхний огнооноос хойших хоног) — завсарласан өдрүүд бодит
      // зайгаараа харагдана.
      final parsed = <({DateTime? date, double value})>[];
      for (final row in data) {
        final v = row['CLOSEPRICE'] ??
            row['close'] ??
            row['price'] ??
            row['CLOSE'] ??
            row['value'] ??
            row['val'];
            
        final value = v is num
            ? v.toDouble()
            : double.tryParse(v?.toString() ?? '') ?? 0.0;
        if (value <= 0) continue;

        final rawDate =
            row['DATE'] ?? row['date'] ?? row['TRADEDATE'] ?? row['TRADEDAY'];
        var date = parseStockDate(rawDate);
        // ISO8601 форматтай байвал fallback оролдоно
        if (date == null && rawDate != null) {
          date = DateTime.tryParse(rawDate.toString());
        }

        parsed.add((date: date, value: value));
      }

      final firstDate = parsed.isEmpty ? null : parsed.first.date;
      final spots = <FlSpot>[
        for (var i = 0; i < parsed.length; i++)
          FlSpot(
            firstDate == null || parsed[i].date == null
                ? i.toDouble()
                : parsed[i].date!.difference(firstDate).inDays.toDouble(),
            parsed[i].value,
          ),
      ];

      if (!mounted) return;
      setState(() {
        _spots = spots;
        _startDate = firstDate;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    )
                  : FinanceChart(
                      spots: _spots.isEmpty ? null : _spots,
                      height: 200,
                      startDate: _startDate,
                    ),
        ),
        const SizedBox(height: 16),
        _buildPeriodSelector(theme, extendedColors),
      ],
    );
  }

  Widget _buildPeriodSelector(ThemeData theme, ExtendedColors extendedColors) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      _Period.d1: l10n.d1,
      _Period.d7: l10n.d7,
      _Period.m1: l10n.m1,
      _Period.m3: l10n.m3,
      _Period.y1: l10n.y1,
      _Period.all: l10n.all,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _Period.values.map((p) {
          final isSelected = p == _selected;
          return TextButton(
            onPressed: () {
              if (p == _selected) return;
              setState(() => _selected = p);
              _fetch();
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              labels[p]!,
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
