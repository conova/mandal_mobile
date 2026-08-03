import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mandal_capital/widgets/currency_suffix_formatter.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class BondTradingQuantitySelector extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<String> onChanged;

  const BondTradingQuantitySelector({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onIncrease,
    required this.onDecrease,
    required this.onChanged,
  });

  @override
  State<BondTradingQuantitySelector> createState() => _BondTradingQuantitySelectorState();
}

class _BondTradingQuantitySelectorState extends State<BondTradingQuantitySelector> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
    widget.controller.text = CurrencySuffixFormatter.format(widget.controller.text, suffix: '');
  }

  @override
  void didUpdateWidget(BondTradingQuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (!widget.focusNode.hasFocus && widget.controller.text.isEmpty) {
      widget.controller.text = '0';
      widget.onChanged('0');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return GestureDetector(
      onTap: () => widget.focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: extendedColors.neutral500),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quantityLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral200,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    keyboardType: TextInputType.number,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.focusNode.hasFocus
                          ? extendedColors.primaryMain
                          : extendedColors.neutral100,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: widget.onChanged,
                  ),
                ),
                Row(
                  children: [
                    _buildCircleButton('minus', widget.onDecrease, extendedColors),
                    const SizedBox(width: 8),
                    _buildCircleButton('plus', widget.onIncrease, extendedColors),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
    String icon,
    VoidCallback onTap,
    ExtendedColors extendedColors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomSvgIcon(icon, size: 20, color: extendedColors.neutral100),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    final number = BigInt.tryParse(digitsOnly);
    if (number == null) return oldValue;

    final formatted = _formatter.format(number.toInt());

    int selectionOffset = formatted.length - (newValue.text.length - newValue.selection.baseOffset);
    if (selectionOffset < 0) selectionOffset = 0;
    if (selectionOffset > formatted.length) selectionOffset = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}
