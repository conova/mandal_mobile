import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';

import 'custom_svg_icon.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final String? hint;
  final bool isPassword;
  final Widget? suffix;
  final TextEditingController? controller;
  final String? errorText; // External error control
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  // New Validation Fields
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(String?)? onSaved;
  final FocusNode? focusNode;
  final int? maxLength;
  final bool enabled;
  final TextAlign textAlign;
  final bool showCounter;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInput({
    super.key,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.suffix,
    this.controller,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onSaved,
    this.focusNode,
    this.maxLength,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.showCounter = true,
    this.inputFormatters,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _internalErrorText; // Tracks validation errors internally

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(CustomInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      _focusNode.removeListener(_handleFocusChange);

      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    // Priority: External errorText > Internal validation error
    final String? currentError = widget.errorText ?? _internalErrorText;
    final bool hasError = currentError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ), // Adjusted vertical padding
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
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: widget.isPassword ? _obscureText : false,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              textAlign: widget.textAlign,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              validator: (value) {
                // Run the custom validator
                final result = widget.validator?.call(value);
                // Update the UI state to show the red border
                if (_internalErrorText != result) {
                  // This schedules the update for the very next frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      // Ensure the widget still exists
                      setState(() {
                        _internalErrorText = result;
                      });
                    }
                  });
                }
                return result;
              },
              autovalidateMode: widget.autovalidateMode,
              onSaved: widget.onSaved,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral100,
              ),
              decoration: InputDecoration(
                labelText: widget.label.isEmpty ? null : widget.label,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: AppTextStyles.light,
                  color: extendedColors.neutral200,
                ),
                hintText: widget.hint,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                  fontWeight: AppTextStyles.light,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: widget.showCounter ? null : '',
                errorStyle: const TextStyle(
                  height: 0,
                  fontSize: 0,
                ), // Hide default error text
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: CustomSvgIcon(
                          _obscureText
                              ? 'eye-open'
                              : 'eye-closed',
                          color: extendedColors.neutral300,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : widget.suffix,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 7, left: 16),
            child: Text(
              currentError,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: AppTextStyles.light,
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
