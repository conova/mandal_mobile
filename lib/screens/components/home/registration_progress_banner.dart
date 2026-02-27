import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class RegistrationProgressBanner extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final VoidCallback onStartPressed;

  const RegistrationProgressBanner({
    super.key,
    required this.progress,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.khurSystem,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        l10n.registrationProgress(percent.toString()),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral200,
                        ),
                      ),
                      Text(
                        percent.toString() + "%",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral100,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: extendedColors.yellow,
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onStartPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: extendedColors.yellow,
                  foregroundColor: extendedColors.bgBase,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15.5,
                  ),
                ),
                child: Text(
                  l10n.start,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.bgBase,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.disabledColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(extendedColors.yellow),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
