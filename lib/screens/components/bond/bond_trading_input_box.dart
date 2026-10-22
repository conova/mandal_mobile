import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

import '../../../widgets/currency_suffix_formatter.dart';

class BondTradingInputBox extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String currencySymbol;

  /// 0 = whole numbers only. Use 2 if the price can have decimals.
  final int maxDecimals;

  const BondTradingInputBox({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    this.currencySymbol = '₮',
    this.maxDecimals = 0,
  });

  @override
  State<BondTradingInputBox> createState() => _BondTradingInputBoxState();
}

class _BondTradingInputBoxState extends State<BondTradingInputBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_keepCursorBeforeSuffix);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.text.isNotEmpty) {
        final formatted = CurrencySuffixFormatter.format(
          widget.controller.text,
          suffix: widget.currencySymbol,
          maxDecimals: widget.maxDecimals,
        );
        if (widget.controller.text != formatted) {
          widget.controller.text = formatted;
        }
      }
    });
  }

  @override
  void didUpdateWidget(BondTradingInputBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_keepCursorBeforeSuffix);
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _keepCursorBeforeSuffix() {
    final c = widget.controller;
    final s = widget.currencySymbol;
    final sel = c.selection;
    if (s.isEmpty || !sel.isValid || !sel.isCollapsed) return;
    if (!c.text.endsWith(s)) return;

    final maxOffset = c.text.length - s.length;
    if (sel.baseOffset > maxOffset) {
      c.selection = TextSelection.collapsed(offset: maxOffset);
    }
  }

  void _handleFocusChange() {
    if (!widget.focusNode.hasFocus && widget.controller.text.isEmpty) {
      widget.controller.text = CurrencySuffixFormatter.format(
        '0',
        suffix: widget.currencySymbol,
        maxDecimals: widget.maxDecimals,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return GestureDetector(
      onTap: () => widget.focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: extendedColors.neutral500),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w200,
                color: extendedColors.neutral200,
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
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: widget.maxDecimals > 0,
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.focusNode.hasFocus
                          ? extendedColors.primaryMain
                          : extendedColors.neutral100,
                    ),
                    // IMPORTANT: no FilteringTextInputFormatter.digitsOnly here
                    inputFormatters: [
                      CurrencySuffixFormatter(
                        suffix: widget.currencySymbol,
                        maxDecimals: widget.maxDecimals,
                      ),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}