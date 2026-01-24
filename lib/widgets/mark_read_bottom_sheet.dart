import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class MarkReadBottomSheet extends StatelessWidget {
  const MarkReadBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerTheme.color ?? theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.markAllReadTitle,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.markAllReadDesc,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.confirm,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
                foregroundColor: colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.back,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
