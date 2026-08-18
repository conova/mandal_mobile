import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class CustomRoundSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final Color borderColor;
  final double borderWidth;

  const CustomRoundSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

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

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, enabledThumbRadius, fillPaint);
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);
  }
}

class BondPriceSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onChanged;

  const BondPriceSlider({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<BondPriceSlider> createState() => _BondPriceSliderState();
}

class _BondPriceSliderState extends State<BondPriceSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  double get _progress =>
      (_currentValue - widget.min) / (widget.max - widget.min);

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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: extendedColors.neutral500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.sellPrice,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: extendedColors.neutral300,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.executionProbability,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getProbabilityText(l10n),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _getProbabilityColor(extendedColors),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBars(extendedColors),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_currentValue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₮',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: theme.sliderTheme.copyWith(
              trackHeight: 12,
              thumbShape: CustomRoundSliderThumbShape(
                enabledThumbRadius: 12,
                borderColor: extendedColors.primaryMain,
                borderWidth: 4,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: extendedColors.primaryMain,
              inactiveTrackColor: extendedColors.bgSecondary,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: _currentValue,
              min: widget.min,
              max: widget.max,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
                widget.onChanged(value);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${widget.min.toInt()}₮',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: AppTextStyles.light,
                  color: extendedColors.neutral300,
                ),
              ),
              Text(
                'Max: ${widget.max.toInt()}₮',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: AppTextStyles.light,
                  color: extendedColors.neutral300,
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
      children: List.generate(3, (index) {
        return Container(
          width: 4,
          height: 8 + (index * 4).toDouble(),
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: index < activeBars
                ? _getProbabilityColor(extendedColors)
                : extendedColors.neutral500,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
