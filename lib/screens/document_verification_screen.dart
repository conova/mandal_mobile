import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.document,
                style: AppTextStyles.h2.copyWith(
                  color: theme.colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.documentDesc,
                style: AppTextStyles.body2.copyWith(color: theme.disabledColor),
              ),
              const SizedBox(height: 32),
              _buildDocItem(l10n.idFront, _isIdFrontDone, () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/camera_overlay',
                  arguments: 'id',
                );
                if (result == true) setState(() => _isIdFrontDone = true);
              }),
              _buildDocItem(l10n.idBack, _isIdBackDone, () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/camera_overlay',
                  arguments: 'id',
                );
                if (result == true) setState(() => _isIdBackDone = true);
              }),
              _buildDocItem(l10n.selfiePhoto, _isSelfieDone, () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/camera_overlay',
                  arguments: 'selfie',
                );
                if (result == true) setState(() => _isSelfieDone = true);
              }),
              const SizedBox(height: 32),
              Text(
                l10n.photoRequirements,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              _buildRequirement(l10n.reqCorner),
              _buildRequirement(l10n.reqValid),
              _buildRequirement(l10n.reqClear),
              _buildRequirement(l10n.reqReadable),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAllDone
                      ? () =>
                            Navigator.pushNamed(context, '/onboarding_success')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAllDone
                        ? extendedColors.primaryMain
                        : theme.disabledColor.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: theme.disabledColor.withOpacity(
                      0.1,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    l10n.sendPhoto,
                    style: AppTextStyles.body1.copyWith(
                      color: _isAllDone ? Colors.white : theme.disabledColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocItem(String title, bool isDone, VoidCallback onTap) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.disabledColor.withOpacity(0.1), // Placeholder
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDone ? l10n.editPhoto : l10n.addPhoto,
                    style: AppTextStyles.body2.copyWith(
                      color: isDone
                          ? extendedColors.primaryMain
                          : theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check, size: 18, color: extendedColors.primaryMain),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTextStyles.body2.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
