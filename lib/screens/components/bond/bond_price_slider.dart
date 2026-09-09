import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';

// Keeps custom shapes intact
class CustomCapsuleSliderThumbShape extends SliderComponentShape {
  final Size thumbSize;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final Color dotColor;

  const CustomCapsuleSliderThumbShape({
    this.thumbSize = const Size(28, 48),
    this.radius = 12,
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderWidth = 1.5,
    this.dotColor = const Color(0xFFC4C4C4),
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => thumbSize;

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final rect = Rect.fromCenter(
      center: center,
      width: thumbSize.width,
      height: thumbSize.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(rrect, Paint()..color = Colors.white);

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    final dotPaint = Paint()..color = dotColor;
    const double dotRadius = 1.8;
    const double dx = 4.5;
    const double dy = 7.0;

    for (int col in [-1, 1]) {
      for (int row in [-1, 0, 1]) {
        canvas.drawCircle(
          Offset(center.dx + (col * dx), center.dy + (row * dy)),
          dotRadius,
          dotPaint,
        );
      }
    }
  }
}

class FullWidthTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 6.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class CustomLineTickMarkShape extends SliderTickMarkShape {
  final double tickHeight;

  const CustomLineTickMarkShape({this.tickHeight = 6.0});

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    required bool isEnabled,
  }) {
    return Size(2.0, tickHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> enableAnimation,
        required bool isEnabled,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required Offset thumbCenter,
      }) {
    if ((center.dx - thumbCenter.dx).abs() < 14) return;

    final Paint paint = Paint()
      ..color = center.dx <= thumbCenter.dx
          ? (sliderTheme.activeTickMarkColor ?? Colors.white)
          : (sliderTheme.inactiveTickMarkColor ?? Colors.grey)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    context.canvas.drawLine(
      Offset(center.dx, center.dy - (tickHeight / 2)),
      Offset(center.dx, center.dy + (tickHeight / 2)),
      paint,
    );
  }
}

/// Dynamic Formatter for comma-separated thousands values during typing
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String cleanText = newValue.text.replaceAll(',', '');
    final double? parsed = double.tryParse(cleanText);

    if (parsed == null) return oldValue;

    final String formatted = parsed.toInt().toString().replaceAllMapped(
      RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
          (Match m) => "${m[1]},",
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class BondPriceSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final double? step;
  final ValueChanged<double> onChanged;
  final BorderRadiusGeometry? borderRadius;

  const BondPriceSlider({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.onChanged,
    this.step,
    this.borderRadius,
  });

  @override
  State<BondPriceSlider> createState() => _BondPriceSliderState();
}

class _BondPriceSliderState extends State<BondPriceSlider> {
  late double _currentValue;
  bool _isEditing = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _textController = TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _submitValue(_textController.text);
      }
    });
  }

  @override
  void didUpdateWidget(BondPriceSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _currentValue = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double get _progress =>
      (_currentValue - widget.min) / (widget.max - widget.min);

  BorderRadiusGeometry? get borderRadius => widget.borderRadius;

  String _formatPrice(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
          (Match m) => "${m[1]},",
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _textController.text = _formatPrice(_currentValue);
    });
    _focusNode.requestFocus();
  }

  void _submitValue(String input) {
    final cleanInput = input.replaceAll(',', '').replaceAll('₮', '').trim();
    double parsedValue = double.tryParse(cleanInput) ?? _currentValue;

    // Enforce strictly min <= value <= max
    parsedValue = parsedValue.clamp(widget.min, widget.max);

    // Apply steps if configured
    if (widget.step != null && widget.step! > 0) {
      parsedValue = (parsedValue / widget.step!).round() * widget.step!;
    }

    setState(() {
      _currentValue = parsedValue;
      _isEditing = false;
    });

    widget.onChanged(parsedValue);
  }

  String _getProbabilityText(AppLocalizations l10n) {
    if (_progress < 0.3) return l10n.high;
    if (_progress < 0.7) return l10n.medium;
    return l10n.low;
  }

  Color _getProbabilityColor(ExtendedColors extendedColors) {
    if (_progress < 0.3) return extendedColors.primaryMain;
    if (_progress < 0.7) return extendedColors.orange;
    return extendedColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final int? divisions = widget.step != null && widget.step! > 0
        ? ((widget.max - widget.min) / widget.step!).round()
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        border: Border.all(color: extendedColors.neutral500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sellPrice,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _isEditing
                        ? IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: extendedColors.primary500,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(),
                          ],
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: extendedColors.neutral100,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            suffixText: '₮',
                            suffixStyle:
                            theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: extendedColors.neutral100,
                            ),
                          ),
                          onSubmitted: _submitValue,
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: _startEditing,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_formatPrice(_currentValue)}₮',
                            style:
                            theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: extendedColors.neutral100,
                            ),
                          ),
                          const SizedBox(width: 6),
                          CustomSvgIcon(
                            'edit-03',
                            size: 18,
                            color: extendedColors.primaryMain,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.executionProbability,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getProbabilityText(l10n),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _getProbabilityColor(extendedColors),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        _buildBars(extendedColors),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: theme.sliderTheme.copyWith(
              trackHeight: 6,
              trackShape: FullWidthTrackShape(),
              thumbShape: const CustomCapsuleSliderThumbShape(),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: extendedColors.primary500,
              inactiveTrackColor: extendedColors.bgSecondary,
              tickMarkShape: const CustomLineTickMarkShape(),
              activeTickMarkColor: extendedColors.neutral300,
              inactiveTickMarkColor: extendedColors.neutral500,
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: _currentValue,
              min: widget.min,
              max: widget.max,
              divisions: divisions,
              onChanged: (value) {
                double snappedValue = value;
                if (widget.step != null && widget.step! > 0) {
                  snappedValue = (value / widget.step!).round() * widget.step!;
                }

                setState(() {
                  _currentValue = snappedValue;
                });
                widget.onChanged(snappedValue);
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${widget.min.toInt()}₮',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: AppTextStyles.light,
                  color: extendedColors.neutral200,
                ),
              ),
              Text(
                'Max: ${widget.max.toInt()}₮',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: AppTextStyles.light,
                  color: extendedColors.neutral200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBars(ExtendedColors extendedColors) {
    int activeBars = 1;
    if (_progress < 0.3) {
      activeBars = 3;
    } else if (_progress < 0.7) {
      activeBars = 2;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8 + (index * 8).toDouble(),
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: index < activeBars
                ? _getProbabilityColor(extendedColors)
                : extendedColors.neutral500,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}