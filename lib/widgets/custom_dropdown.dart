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
            // Fixed: Padding and child must be inside the Container
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError
                    ? colorScheme.error
                    : (_isFocused ? theme.primaryColor : extendedColors.neutral500),
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant, // Better for labels
                    fontSize: 12, // Usually labels are smaller than the value
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: widget.value,
                    items: widget.items,
                    onChanged: widget.onChanged,
                    isExpanded: true,
                    isDense: true,
                    icon: Icon(Icons.expand_more, color: theme.disabledColor),
                    style: TextStyle(
                      fontSize: 16,
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
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
