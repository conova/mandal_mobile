import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/stock_row_format.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/finance_chart.dart';

enum StockPeriod { d1, d7, m1, m3, y1, all }

/// Stock chart — `/stocks/{SYMBOL}/chart` API-аас өгөгдөл татаж зурна.
/// `symbol` дамжуулаагүй бол placeholder зурна (хуучин зан хадгална).
class StockDetailChart extends StatefulWidget {
  final String? symbol;
  final ValueChanged<StockPeriod>? onPeriodChanged;

  /// Дата ачаалагдсаны дараа — сонгосон хугацааны өөрчлөлтийн хувь
  /// ((сүүлийн − эхний) / эхний × 100). Дата хоосон бол null.
  final ValueChanged<double?>? onPeriodChangePercent;

  const StockDetailChart({
    super.key,
    this.symbol,
    this.onPeriodChanged,
    this.onPeriodChangePercent,
  });

  @override
  State<StockDetailChart> createState() => _StockDetailChartState();
}

class _StockDetailChartState extends State<StockDetailChart> {
  StockPeriod _selected = StockPeriod.d1;
  List<FlSpot> _spots = const [];

  /// Арилжаалагдсан хэмжээ (count) — _spots-той ижил дараалал
  List<double> _volumes = const [];
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
      StockPeriod.d1 => (now.subtract(const Duration(days: 1)), now),
      StockPeriod.d7 => (now.subtract(const Duration(days: 7)), now),
      StockPeriod.m1 => (DateTime(now.year, now.month - 1, now.day), now),
      StockPeriod.m3 => (DateTime(now.year, now.month - 3, now.day), now),
      StockPeriod.y1 => (DateTime(now.year - 1, now.month, now.day), now),
      StockPeriod.all => (DateTime(2000, 1, 1), now),
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
      final data =
          await auth.getStockChart(sym, start: _fmt(start), end: _fmt(end));

      // Хариунаас огноо + үнийг задална. X тэнхлэг: цэгийн дараалал
      // (арилжаагүй өдрүүдэд зай гаргахгүй — цэгүүд ойрхон залгана)
      final parsed = <({DateTime? date, double value, double volume})>[];
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

        // Арилжаалагдсан хэмжээ
        final c = row['cnt'] ??
            row['CNT'] ??
            row['count'] ??
            row['COUNT'] ??
            row['volume'] ??
            row['VOLUME'];
        final volume = c is num
            ? c.toDouble()
            : double.tryParse(c?.toString() ?? '') ?? 0.0;

        parsed.add((date: date, value: value, volume: volume));
      }

      // X нь дараалал тул огноогоор эрэмбэлнэ (огноогүй мөр байрандаа)
      if (parsed.every((p) => p.date != null)) {
        parsed.sort((a, b) => a.date!.compareTo(b.date!));
      }
      final spots = <FlSpot>[
        for (var i = 0; i < parsed.length; i++)
          FlSpot(i.toDouble(), parsed[i].value),
      ];

      if (!mounted) return;
      setState(() {
        _spots = spots;
        _volumes = [for (final p in parsed) p.volume];
        _isLoading = false;
      });
      widget.onPeriodChangePercent?.call(
        spots.isEmpty || spots.first.y == 0
            ? null
            : (spots.last.y - spots.first.y) / spots.first.y * 100,
      );
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
          height: 250,
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
                      height: 250,
                      volumes: _volumes,
                      // Сонгосон хугацааны эхний утгаас өссөн/тэнцүү → primary,
                      // буурсан → улаан
                      isRising: _spots.isEmpty
                          ? null
                          : _spots.last.y >= _spots.first.y,
                      changeTooltip: true,
                      showGrid: true,
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
      StockPeriod.d1: l10n.d1,
      StockPeriod.d7: l10n.d7,
      StockPeriod.m1: l10n.m1,
      StockPeriod.m3: l10n.m3,
      StockPeriod.y1: l10n.y1,
      StockPeriod.all: l10n.all,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: StockPeriod.values.map((p) {
          final isSelected = p == _selected;
          return TextButton(
            onPressed: () {
              if (p == _selected) return;
              setState(() => _selected = p);
              widget.onPeriodChanged?.call(p);
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
