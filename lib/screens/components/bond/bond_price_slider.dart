import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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

  String _getProbabilityText(AppLocalizations l10n) {
    double progress = (_currentValue - widget.min) / (widget.max - widget.min);
    if (progress < 0.3) return l10n.high;
    if (progress < 0.7) return l10n.medium;
    return l10n.low;
  }

  Color _getProbabilityColor() {
    double progress = (_currentValue - widget.min) / (widget.max - widget.min);
    if (progress < 0.3) return const Color(0xFF00A389); // Green
    if (progress < 0.7) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.sellPrice,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.executionProbability,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getProbabilityText(l10n),
                    style: TextStyle(
                      color: _getProbabilityColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBars(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_currentValue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₮',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: theme.sliderTheme.copyWith(
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 2,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: const Color(0xFF00A389),
              inactiveTrackColor: theme.colorScheme.surfaceVariant,
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
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              Text(
                'Max: ${widget.max.toInt()}₮',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBars() {
    double progress = (_currentValue - widget.min) / (widget.max - widget.min);
    int activeBars = 1;
    if (progress < 0.3)
      activeBars = 3;
    else if (progress < 0.7)
      activeBars = 2;

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 4,
          height: 8 + (index * 4).toDouble(),
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: index < activeBars
                ? _getProbabilityColor()
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
