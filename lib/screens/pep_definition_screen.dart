import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/circle_back_button.dart';

class PepDefinitionScreen extends StatelessWidget {
  const PepDefinitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: _PepAppBar(theme: theme, extendedColors: extendedColors),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.pepDefinition,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: AppTextStyles.semiBold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.pepDefinitionFull,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: AppTextStyles.extraLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PepAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _PepAppBar({required this.theme, required this.extendedColors});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircleBackButton(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
