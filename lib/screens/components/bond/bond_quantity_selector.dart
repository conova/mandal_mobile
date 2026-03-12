import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class BondQuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const BondQuantitySelector({
    super.key,
    this.initialQuantity = 0,
    required this.maxQuantity,
    required this.onChanged,
  });

  @override
  State<BondQuantitySelector> createState() => _BondQuantitySelectorState();
}

class _BondQuantitySelectorState extends State<BondQuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _updateQuantity(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(0, widget.maxQuantity);
      widget.onChanged(_quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
          Text(
            l10n.buyQuantity,
            style: theme.textTheme.labelMedium?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_quantity',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
              Row(
                children: [
                  _buildButton(
                    Icons.remove,
                    () => _updateQuantity(-1),
                    extendedColors,
                  ),
                  const SizedBox(width: 12),
                  _buildButton(
                    Icons.add,
                    () => _updateQuantity(1),
                    extendedColors,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.availableQuantity}: ${widget.maxQuantity} ш',
            style: theme.textTheme.labelMedium?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    IconData icon,
    VoidCallback onPressed,
    ExtendedColors extendedColors,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: extendedColors.neutral100),
      ),
    );
  }
}
