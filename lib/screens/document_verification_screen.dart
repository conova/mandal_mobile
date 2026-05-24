import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
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
  String? _idFrontPath;
  String? _idBackPath;
  String? _selfiePath;
  bool _initialized = false;

  bool get _isIdFrontDone => _idFrontPath != null;
  bool get _isIdBackDone => _idBackPath != null;
  bool get _isSelfieDone => _selfiePath != null;

  bool get _isAllDone => _isIdFrontDone && _isIdBackDone && _isSelfieDone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    // `userInfo.document` доторх статусаар анх дүүргэнэ. Сервэрт аль хэдийн
    // илгээгдсэн баримтуудыг 'done' sentinel-ээр тэмдэглэнэ — энэ нь UI-д
    // галерийн thumbnail биш `Icons.camera_alt` иконыг бус,
    // `editPhoto` шошготой "хийгдсэн" төлөвт харагдана.
    final auth = context.read<AuthService>();
    setState(() {
      if (auth.isIdFrontUploaded) _idFrontPath = 'done';
      if (auth.isIdBackUploaded) _idBackPath = 'done';
      if (auth.isSelfieUploaded) _selfiePath = 'done';
    });
  }

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
                idFrontPath: _idFrontPath,
                idBackPath: _idBackPath,
                selfiePath: _selfiePath,
                onIdFrontTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'id',
                  );
                  if (result != null) {
                    setState(() {
                      _idFrontPath = result is String ? result : 'done';
                    });
                  }
                },
                onIdBackTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'id',
                  );
                  if (result != null) {
                    setState(() {
                      _idBackPath = result is String ? result : 'done';
                    });
                  }
                },
                onSelfieTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'selfie',
                  );
                  if (result != null) {
                    setState(() {
                      _selfiePath = result is String ? result : 'done';
                    });
                  }
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
  final String? idFrontPath;
  final String? idBackPath;
  final String? selfiePath;
  final VoidCallback onIdFrontTap;
  final VoidCallback onIdBackTap;
  final VoidCallback onSelfieTap;

  const _DocItemList({
    required this.l10n,
    required this.isIdFrontDone,
    required this.isIdBackDone,
    required this.isSelfieDone,
    this.idFrontPath,
    this.idBackPath,
    this.selfiePath,
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
          imagePath: idFrontPath,
          onTap: onIdFrontTap,
        ),
        _DocItem(
          title: l10n.idBack,
          isDone: isIdBackDone,
          imagePath: idBackPath,
          onTap: onIdBackTap,
        ),
        _DocItem(
          title: l10n.selfiePhoto,
          isDone: isSelfieDone,
          imagePath: selfiePath,
          onTap: onSelfieTap,
        ),
      ],
    );
  }
}

class _DocItem extends StatelessWidget {
  final String title;
  final bool isDone;
  final String? imagePath;
  final VoidCallback onTap;

  const _DocItem({
    required this.title,
    required this.isDone,
    this.imagePath,
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: isDone && imagePath != null && imagePath != 'done'
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : Icon(
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
