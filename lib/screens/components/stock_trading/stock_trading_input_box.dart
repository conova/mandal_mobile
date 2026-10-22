import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

import '../../../widgets/currency_suffix_formatter.dart';

class StockTradingInputBox extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? suffixText;
  final VoidCallback? onSuffixTap;
  final String currencySymbol;
  final bool readOnly;

  /// Allowed decimal places. 0 = whole numbers only.
  final int maxDecimals;

  const StockTradingInputBox({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    this.suffixText,
    this.onSuffixTap,
    this.currencySymbol = '₮',
    this.readOnly = false,
    this.maxDecimals = 2,
  });

  @override
  State<StockTradingInputBox> createState() => _StockTradingInputBoxState();
}

class _StockTradingInputBoxState extends State<StockTradingInputBox> {
  String _fmt(String value) => CurrencySuffixFormatter.format(
    value,
    suffix: widget.currencySymbol,
    maxDecimals: widget.maxDecimals,
  );

  /// Index right before the currency symbol (end of the digits).
  int get _digitsEnd {
    final t = widget.controller.text;
    final s = widget.currencySymbol;
    return (s.isNotEmpty && t.endsWith(s)) ? t.length - s.length : t.length;
  }

  bool get _isZero {
    final t = widget.controller.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return (double.tryParse(t) ?? 0) == 0;
  }

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_keepCursorBeforeSuffix);

    // Ensure initial text is formatted with the correct currency symbol
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final text = widget.controller.text;
      final formatted = _fmt(text.isEmpty ? '0' : text);
      if (text != formatted) widget.controller.text = formatted;
    });
  }

  @override
  void didUpdateWidget(StockTradingInputBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_keepCursorBeforeSuffix);
      widget.controller.addListener(_keepCursorBeforeSuffix);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_keepCursorBeforeSuffix);
    super.dispose();
  }

  /// The cursor must never sit after the currency symbol.
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
    final c = widget.controller;

    if (!widget.focusNode.hasFocus) {
      // Lost focus: never leave it empty, and clean up things like "5.₮".
      final formatted = _fmt(c.text.isEmpty ? '0' : c.text);
      if (c.text != formatted) c.text = formatted;
    } else if (!widget.readOnly) {
      // Gained focus. Wait one frame so a tap on the field can place its own
      // cursor first, then fix up the selection.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.focusNode.hasFocus) return;
        if (_isZero) {
          // "0₮" -> select the digits so the first key replaces the 0
          c.selection = TextSelection(baseOffset: 0, extentOffset: _digitsEnd);
        } else {
          _keepCursorBeforeSuffix();
        }
      });
    }
    setState(() {});
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    final raw = data?.text;
    if (raw == null) return;

    final cleanText = raw.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleanText.isEmpty) return;

    final formatted = _fmt(cleanText);
    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length - widget.currencySymbol.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return GestureDetector(
      onTap: () {
        if (!widget.readOnly) {
          widget.focusNode.requestFocus();
        }
      },
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
                    readOnly: widget.readOnly,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: widget.maxDecimals > 0,
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.focusNode.hasFocus
                          ? extendedColors.primaryMain
                          : extendedColors.neutral100,
                    ),
                    // IMPORTANT: no FilteringTextInputFormatter here. It would
                    // strip the symbol and commas before the formatter runs
                    // and break the cursor handling.
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

                // RIGHT SIDE: Action button (e.g. Paste)
                if (widget.suffixText != null && !widget.readOnly) ...[
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () async {
                      if (widget.onSuffixTap != null) {
                        widget.onSuffixTap!();
                      } else {
                        await _paste();
                      }
                    },
                    child: Text(
                      widget.suffixText!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.primaryMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}