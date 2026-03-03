import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  bool _isIdFrontDone = false;
  bool _isIdBackDone = false;
  bool _isSelfieDone = false;

  bool get _isAllDone => _isIdFrontDone && _isIdBackDone && _isSelfieDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: _DocAppBar(theme: theme, extendedColors: extendedColors),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _DocHeader(l10n: l10n, theme: theme),
              const SizedBox(height: 32),
              _DocItemList(
                l10n: l10n,
                isIdFrontDone: _isIdFrontDone,
                isIdBackDone: _isIdBackDone,
                isSelfieDone: _isSelfieDone,
                onIdFrontTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'id',
                  );
                  if (result == true) setState(() => _isIdFrontDone = true);
                },
                onIdBackTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'id',
                  );
                  if (result == true) setState(() => _isIdBackDone = true);
                },
                onSelfieTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'selfie',
                  );
                  if (result == true) setState(() => _isSelfieDone = true);
                },
              ),
              const SizedBox(height: 32),
              _DocRequirements(
                l10n: l10n,
                theme: theme,
                extendedColors: extendedColors,
              ),
              const Spacer(),
              _DocActionButtons(
                l10n: l10n,
                isAllDone: _isAllDone,
                onSend: () {
                  Navigator.pushNamed(context, '/onboarding_success');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _DocAppBar({required this.theme, required this.extendedColors});

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

class _DocHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _DocHeader({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    final extendedColors = theme.extension<ExtendedColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.document,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onBackground,
            fontWeight: AppTextStyles.semiBold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.documentDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral200,
            fontWeight: AppTextStyles.light,
          ),
        ),
      ],
    );
  }
}

class _DocItemList extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isIdFrontDone;
  final bool isIdBackDone;
  final bool isSelfieDone;
  final VoidCallback onIdFrontTap;
  final VoidCallback onIdBackTap;
  final VoidCallback onSelfieTap;

  const _DocItemList({
    required this.l10n,
    required this.isIdFrontDone,
    required this.isIdBackDone,
    required this.isSelfieDone,
    required this.onIdFrontTap,
    required this.onIdBackTap,
    required this.onSelfieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DocItem(
          title: l10n.idFront,
          isDone: isIdFrontDone,
          onTap: onIdFrontTap,
        ),
        _DocItem(title: l10n.idBack, isDone: isIdBackDone, onTap: onIdBackTap),
        _DocItem(
          title: l10n.selfiePhoto,
          isDone: isSelfieDone,
          onTap: onSelfieTap,
        ),
      ],
    );
  }
}

class _DocItem extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onTap;

  const _DocItem({
    required this.title,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: extendedColors.neutral300,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppTextStyles.light,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDone ? l10n.editPhoto : l10n.addPhoto,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppTextStyles.light,
                      color: isDone
                          ? extendedColors.primaryMain
                          : extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: extendedColors.neutral400),
          ],
        ),
      ),
    );
  }
}

class _DocRequirements extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _DocRequirements({
    required this.l10n,
    required this.theme,
    required this.extendedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.photoRequirements,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: AppTextStyles.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        _RequirementItem(
          text: l10n.reqCorner,
          extendedColors: extendedColors,
          theme: theme,
        ),
        _RequirementItem(
          text: l10n.reqValid,
          extendedColors: extendedColors,
          theme: theme,
        ),
        _RequirementItem(
          text: l10n.reqClear,
          extendedColors: extendedColors,
          theme: theme,
        ),
        _RequirementItem(
          text: l10n.reqReadable,
          extendedColors: extendedColors,
          theme: theme,
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final ExtendedColors extendedColors;
  final ThemeData theme;

  const _RequirementItem({
    required this.text,
    required this.extendedColors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check, size: 19, color: extendedColors.primaryMain),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontWeight: AppTextStyles.light,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocActionButtons extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isAllDone;
  final VoidCallback onSend;

  const _DocActionButtons({
    required this.l10n,
    required this.isAllDone,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: extendedColors.neutral500, width: 1.0),
        ),
      ),
      child: CustomButton(
        label: l10n.sendPhoto,
        onPressed: isAllDone ? onSend : null,
        variant: CustomButtonVariant.primary,
      ),
    );
  }
}
