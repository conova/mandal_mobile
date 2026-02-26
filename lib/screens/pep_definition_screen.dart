import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';

class PepDefinitionScreen extends StatelessWidget {
  const PepDefinitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.disabledColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pepDefinition,
              style: AppTextStyles.h2.copyWith(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.pepDefinitionFull,
              style: AppTextStyles.body1.copyWith(
                color: theme.colorScheme.onBackground,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
