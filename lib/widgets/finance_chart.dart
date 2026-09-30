import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../common/stock_row_format.dart';

/// График — `spots` өгөгдсөн бол түүгээр зурна, үгүй бол default sample.
/// minY/maxY автоматаар [spots]-ийн дотроос тооцоологдоно (padding 5% нэмж).
///
/// Хэвтээ тэнхлэгээр pinch zoom + pan хийж болно. Доод өдрийн хуваарь
/// zoom-ийг дагаж хөдөлдөг ба хуваарь дээр tap хийхэд тухайн цэг дээр
/// төвлөж томруулна.
class FinanceChart extends StatefulWidget {
  final List<FlSpot>? spots;

  /// Графикийн өндөр (px)
  final double height;

  /// Эхний цэгийн (x=0) огноо — өгвөл tooltip дээр тухайн өдрийн
  /// огноог утгын хамт харуулна (x тэнхлэг өдрийн нэгжтэй гэж үзнэ)
  final DateTime? startDate;

  const FinanceChart({
    super.key,
    this.spots,
    this.height = 200,
    this.startDate,
  });

  @override
  State<FinanceChart> createState() => _FinanceChartState();
}

class _FinanceChartState extends State<FinanceChart> {
  static const double _maxScale = 20;

  /// Шугамын зузаан
  static const double _lineWidth = 1.5;

  /// Шугамын доорх дүүргэлтийн alpha — дээрээс доош аажмаар бүдгэрнэ.
  /// (1.0 → 0.9 шиг өндөр утга өгвөл дүүргэлт бараг тодорхой болно)
  static const double _fillAlphaTop = 0.6;
  static const double _fillAlphaBottom = 0.15;

  /// График + доод хуваарь хоёулаа нэг transformation хуваалцана
  final TransformationController _transformationController =
  TransformationController();

  @override
  void didUpdateWidget(FinanceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Шинэ дата (жнь өөр хугацааны шүүлтүүр) ирэхэд өмнөх zoom/pan
    // хэвээр үлдвэл график огт өөрчлөгдөөгүй мэт харагдана
    if (!_sameSpots(oldWidget.spots, widget.spots)) {
      _transformationController.value = Matrix4.identity();
    }
  }

  static bool _sameSpots(List<FlSpot>? a, List<FlSpot>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].x != b[i].x || a[i].y != b[i].y) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  static const List<FlSpot> _sampleSpots = [
    FlSpot(0, 0),
  ];

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.day.toString().padLeft(2, '0')}';

  /// Хуваарь дээр tap — тухайн цэг дээр төвлөж 2 дахин томруулна,
  /// дээд хязгаарт хүрсэн байвал анхны байдалд буцаана.
  void _zoomAt(double localX, double width) {
    final m = _transformationController.value;
    final scale = m.getMaxScaleOnAxis();
    if (scale >= _maxScale) {
      _transformationController.value = Matrix4.identity();
      return;
    }
    final tx = m.getTranslation().x;
    final newScale = (scale * 2).clamp(1.0, _maxScale);
    // Tap хийсэн цэгийн доорх контент байрандаа үлдэнэ
    final contentX = (localX - tx) / scale;
    final newTx = (localX - contentX * newScale).clamp(
      width * (1 - newScale),
      0.0,
    );
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(newTx, 0, 0, 1)
      ..scaleByDouble(newScale, newScale, newScale, 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useSpots = (widget.spots != null && widget.spots!.isNotEmpty)
        ? widget.spots!
        : _sampleSpots;

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
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              // Хумих/тэлэх (pinch) болон чирч гүйлгэх — хэвтээ тэнхлэгээр
              transformationConfig: FlTransformationConfig(
                scaleAxis: FlScaleAxis.horizontal,
                maxScale: _maxScale,
                transformationController: _transformationController,
              ),
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                // Tap хийсэн цэгийг сонгож утгыг нь tooltip-оор харуулна
                lineTouchData: LineTouchData(
                  // Нимгэн шугамыг барихад хялбар болгоно
                  touchSpotThreshold: 30,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.inverseSurface.withValues(alpha: 0.9),
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                      // x = эхний огнооноос хойших хоног → тухайн өдрийн огноо
                      final date = widget.startDate?.add(
                        Duration(days: s.x.round()),
                      );
                      return LineTooltipItem(
                        formatStockAmount(s.y),
                        theme.textTheme.labelLarge!.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          if (date != null)
                            TextSpan(
                              text: '\n${_fmtDate(date)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onInverseSurface
                                    .withValues(alpha: 0.7),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                  getTouchedSpotIndicator: (barData, indexes) => indexes
                      .map(
                        (i) => TouchedSpotIndicatorData(
                      FlLine(
                        color: theme.primaryColor.withValues(alpha: 0.5),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                      // Дотор нь тод цэг, гадуур нь хагас тунгалаг halo
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            _HaloDotPainter(
                              color: theme.primaryColor,
                              ringColor: theme.colorScheme.surface,
                            ),
                      ),
                    ),
                  )
                      .toList(),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: useSpots,
                    isCurved: true,
                    // Огцом өөрчлөлттэй цэгүүд дээр муруй хэт давж
                    // "мурилзахаас" сэргийлнэ
                    preventCurveOverShooting: true,
                    curveSmoothness: 0.2,
                    color: theme.primaryColor,
                    barWidth: _lineWidth,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    // Шугамын доорх дүүргэлт: дээрээс доош аажмаар бүдгэрнэ
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.primaryColor.withValues(alpha: _fillAlphaTop),
                          theme.primaryColor
                              .withValues(alpha: _fillAlphaBottom),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Доод босоо зураасууд — 2 зураасын хоорондох зай 1 өдөр.
          // Графикийн zoom-ийг дагана; tap хийхэд тухайн цэг дээр томруулна.
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => _zoomAt(details.localPosition.dx, width),
                child: SizedBox(
                  height: 10,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _transformationController,
                    builder: (context, _) {
                      final m = _transformationController.value;
                      return CustomPaint(
                        painter: _DayTicksPainter(
                          minX: minX,
                          maxX: maxX,
                          scale: m.getMaxScaleOnAxis(),
                          translationX: m.getTranslation().x,
                          color: theme.disabledColor.withValues(alpha: 0.35),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Touch хийсэн цэг: гаднах хагас тунгалаг halo + тод төв цэг (surface өнгийн
/// хүрээтэй).
class _HaloDotPainter extends FlDotPainter {
  final Color color;
  final Color ringColor;
  final double radius;
  final double haloRadius;

  const _HaloDotPainter({
    required this.color,
    required this.ringColor,
    this.radius = 4,
    this.haloRadius = 10,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset center) {
    // Гаднах хагас тунгалаг давхарга
    canvas.drawCircle(
      center,
      haloRadius,
      Paint()..color = color.withValues(alpha: 0.2),
    );
    // Төв цэгийг halo-оос ялгах хүрээ
    canvas.drawCircle(center, radius + 1.5, Paint()..color = ringColor);
    // Төв цэг
    canvas.drawCircle(center, radius, Paint()..color = color);
  }

  @override
  Size getSize(FlSpot spot) => Size.square(haloRadius * 2);

  @override
  Color get mainColor => color;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) => b;

  @override
  List<Object?> get props => [color, ringColor, radius, haloRadius];
}

/// Графикийн доорх өдрийн хуваарийн зураасууд.
/// X тэнхлэг өдрийн нэгжтэй тул зураас бүр 1 өдрийг илтгэнэ;
/// хэт нягтрахаар бол (өдөр бүрд 4px ч хүрэхгүй) алхмыг автоматаар томсгоно.
/// Zoom-ийн scale/translation-ийг дагаж зурагдана.
class _DayTicksPainter extends CustomPainter {
  final double minX;
  final double maxX;
  final double scale;
  final double translationX;
  final Color color;

  _DayTicksPainter({
    required this.minX,
    required this.maxX,
    required this.scale,
    required this.translationX,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final days = (maxX - minX).round();
    if (days <= 0 || size.width <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Харагдаж буй өдрийн тоогоор нягтралыг тохируулна — zoom хийх тусам
    // алхам жижгэрч өдөр бүрийн зураас ил гарна
    const minGapPx = 4.0;
    final visibleDays = days / scale;
    final step = (visibleDays * minGapPx / size.width).ceil().clamp(1, days);

    for (var d = 0; d <= days; d += step) {
      final contentX = d / days * size.width;
      final x = contentX * scale + translationX;
      if (x < -1 || x > size.width + 1) continue;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_DayTicksPainter oldDelegate) =>
      oldDelegate.minX != minX ||
          oldDelegate.maxX != maxX ||
          oldDelegate.scale != scale ||
          oldDelegate.translationX != translationX ||
          oldDelegate.color != color;
}