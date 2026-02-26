import 'package:flutter/material.dart';
import '../../../../theme/extended_colors.dart';

class PasswordValidationRules extends StatelessWidget {
  final bool has8Chars;
  final bool hasUpper;
  final bool hasLower;
  final bool hasNumber;
  final String label8Chars;
  final String labelUpper;
  final String labelLower;
  final String labelNumber;

  const PasswordValidationRules({
    super.key,
    required this.has8Chars,
    required this.hasUpper,
    required this.hasLower,
    required this.hasNumber,
    required this.label8Chars,
    required this.labelUpper,
    required this.labelLower,
    required this.labelNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildValidationRule(label8Chars, has8Chars),
        _buildValidationRule(labelUpper, hasUpper),
        _buildValidationRule(labelLower, hasLower),
        _buildValidationRule(labelNumber, hasNumber),
      ],
    );
  }

  Widget _buildValidationRule(String label, bool isValid) {
    return Builder(
      builder: (context) {
        final extendedColors = Theme.of(context).extension<ExtendedColors>()!;
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 20,
                color: !isValid
                    ? extendedColors.neutral200
                    : extendedColors.primaryMain,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: !isValid
                      ? extendedColors.neutral200
                      : extendedColors.primaryMain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
