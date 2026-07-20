import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';

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
  List<double> _points = const [];
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

      // Хариунаас close үнэ задлах. CLOSEPRICE / close / price гэх мэт түгээмэл түлхүүр шалгана.
      final pts = data
          .map((row) {
            final v = row['CLOSEPRICE'] ?? row['close'] ?? row['price'] ?? row['CLOSE'];
            if (v is num) return v.toDouble();
            if (v is String) return double.tryParse(v) ?? 0.0;
            return 0.0;
          })
          .where((v) => v > 0)
          .toList();

      if (!mounted) return;
      setState(() {
        _points = pts;
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
                  : CustomPaint(
                      painter: _ChartPainter(
                        lineColor: extendedColors.primaryMain,
                        areaColor: extendedColors.primaryMain.withOpacity(0.1),
                        points: _points,
                      ),
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

class _ChartPainter extends CustomPainter {
  final Color lineColor;
  final Color areaColor;
  final List<double> points;

  _ChartPainter({
    required this.lineColor,
    required this.areaColor,
    this.points = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    if (points.isEmpty) {
      // Placeholder зам (хуучин зан)
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
    } else {
      // API өгөгдлийг normalize → path
      final minV = points.reduce((a, b) => a < b ? a : b);
      final maxV = points.reduce((a, b) => a > b ? a : b);
      final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
      final stepX = points.length > 1 ? size.width / (points.length - 1) : size.width;

      for (var i = 0; i < points.length; i++) {
        final x = i * stepX;
        // Дээш мөр болгонд: max → top (0.0), min → bottom (1.0)
        final norm = (points[i] - minV) / range;
        final y = size.height * (1 - norm) * 0.9 + size.height * 0.05;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }

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
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.points != points;
}
