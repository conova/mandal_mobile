import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.errorText,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 75),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: extendedColors.bgBase,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError
                    ? colorScheme.error
                    : (_isFocused
                        ? theme.primaryColor
                        : extendedColors.neutral500),
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.value != null)
                  Text(
                    widget.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: extendedColors.neutral200,
                      fontSize: 12,
                    ),
                  ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: widget.value,
                    hint: Text(
                      widget.label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    items: widget.items,
                    onChanged: widget.onChanged,
                    isExpanded: true,
                    isDense: true,
                    icon: Icon(Icons.expand_more, color: theme.disabledColor),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 7, left: 16),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
