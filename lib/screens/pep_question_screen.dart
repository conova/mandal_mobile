import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';

class PepQuestionScreen extends StatelessWidget {
  const PepQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: _PepAppBar(theme: theme, extendedColors: extendedColors),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: _PepHeaderIcon(extendedColors: extendedColors),
            ),
            const SizedBox(height: 32),
            _PepQuestionContent(
              l10n: l10n,
              theme: theme,
              extendedColors: extendedColors,
            ),
            const SizedBox(height: 64),
            _PepActionButtons(l10n: l10n),
            const Spacer(flex: 3),
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
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: extendedColors.neutral500,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              size: 20,
              color: theme.colorScheme.onBackground,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PepHeaderIcon extends StatelessWidget {
  final ExtendedColors extendedColors;

  const _PepHeaderIcon({required this.extendedColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12),
      padding: EdgeInsets.all(12),
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Image.asset('assets/images/3d_finance.png', fit: BoxFit.contain),
    );
  }
}

class _PepQuestionContent extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _PepQuestionContent({
    required this.l10n,
    required this.theme,
    required this.extendedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pepQuestion,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onBackground,
              fontWeight: AppTextStyles.semiBold,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/pep_definition');
            },
            child: Text(
              l10n.pepDefinition,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.primaryMain,
                decoration: TextDecoration.underline,
                fontWeight: AppTextStyles.regular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PepActionButtons extends StatelessWidget {
  final AppLocalizations l10n;

  const _PepActionButtons({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: l10n.no,
            onPressed: () {
              Navigator.pushNamed(context, '/dan_verification');
            },
            variant: CustomButtonVariant.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: l10n.yes,
            onPressed: () {
              Navigator.pushNamed(context, '/dan_verification');
              Navigator.pop(context, false);
            },
            variant: CustomButtonVariant.secondary,
          ),
        ),
      ],
    );
  }
}
