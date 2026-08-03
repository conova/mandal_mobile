import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';

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
  late TextEditingController _controller;
  late FocusNode _focusNode;

  int get _effectiveMax => widget.maxQuantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity.clamp(0, _effectiveMax);
    _controller = TextEditingController(text: '$_quantity');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _controller.text.isEmpty) {
        _controller.text = '0';
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateQuantity(int delta) {
    final newQuantity = (_quantity + delta).clamp(0, _effectiveMax);
    if (newQuantity != _quantity) {
      setState(() {
        _quantity = newQuantity;
        _controller.text = '$_quantity';
        widget.onChanged(_quantity);
      });
    }
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
        border: _focusNode.hasFocus
          ? Border.all(
            color: extendedColors.primaryMain,
            width: 2,
          )
          : Border.all(
            color: extendedColors.neutral500,
            width: 1,
          ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.buyQuantity,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _MaxQuantityFormatter(_effectiveMax),
                  ],
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    final newQuantity = int.tryParse(value) ?? 0;
                    if (newQuantity != _quantity) {
                      setState(() {
                        _quantity = newQuantity;
                      });
                      widget.onChanged(_quantity);
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${l10n.availableQuantity}: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    Text(
                      '$_effectiveMax ${l10n.bondsPiece}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _buildButton(
                'minus',
                () => _updateQuantity(-1),
                extendedColors,
              ),
              const SizedBox(width: 12),
              _buildButton(
                'plus',
                () => _updateQuantity(1),
                extendedColors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String icon,
    VoidCallback onPressed,
    ExtendedColors extendedColors,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(30),
        ),
        child: CustomSvgIcon(icon, size: 24, color: extendedColors.neutral100),
      ),
    );
  }
}

class _MaxQuantityFormatter extends TextInputFormatter {
  final int max;

  _MaxQuantityFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text);
    if (intValue == null) return oldValue;
    if (intValue > max) {
      return TextEditingValue(
        text: max.toString(),
        selection: TextSelection.collapsed(offset: max.toString().length),
      );
    }
    return newValue;
  }
}
