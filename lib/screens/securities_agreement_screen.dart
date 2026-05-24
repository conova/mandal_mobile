import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_snackbar.dart';

class SecuritiesAgreementScreen extends StatefulWidget {
  const SecuritiesAgreementScreen({super.key});

  @override
  State<SecuritiesAgreementScreen> createState() =>
      _SecuritiesAgreementScreenState();
}

class _SecuritiesAgreementScreenState extends State<SecuritiesAgreementScreen> {
  bool _isAccepted = false;
  bool _isSubmitting = false;

  Future<void> _handleAgree() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final auth = context.read<AuthService>();
      await auth.acceptKycAgreement();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: _AgreementAppBar(theme: theme, extendedColors: extendedColors),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _AgreementHeader(l10n: l10n, theme: theme),
              const SizedBox(height: 24),
              _AgreementContent(l10n: l10n, theme: theme),
              const SizedBox(height: 24),
              _AcceptTermsCheckbox(
                l10n: l10n,
                theme: theme,
                extendedColors: extendedColors,
                isAccepted: _isAccepted,
                onChanged: (value) => setState(() => _isAccepted = value),
              ),
              const SizedBox(height: 24),
              _AgreementActionButtons(
                l10n: l10n,
                isAccepted: _isAccepted,
                isSubmitting: _isSubmitting,
                onAgree: _handleAgree,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _AgreementAppBar({required this.theme, required this.extendedColors});

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

class _AgreementHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _AgreementHeader({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n.securitiesAgreement,
      style: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.onBackground,
        fontWeight: AppTextStyles.semiBold,
      ),
    );
  }
}

class _AgreementContent extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _AgreementContent({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Text(
          l10n.securitiesAgreementContent,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.8),
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class _AcceptTermsCheckbox extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final ExtendedColors extendedColors;
  final bool isAccepted;
  final ValueChanged<bool> onChanged;

  const _AcceptTermsCheckbox({
    required this.l10n,
    required this.theme,
    required this.extendedColors,
    required this.isAccepted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isAccepted),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: extendedColors.neutral400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isAccepted
                    ? extendedColors.primaryMain
                    : Colors.transparent,
                border: Border.all(
                  color: isAccepted
                      ? extendedColors.primaryMain
                      : extendedColors.neutral300,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isAccepted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.acceptTerms,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: AppTextStyles.regular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgreementActionButtons extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isAccepted;
  final bool isSubmitting;
  final VoidCallback onAgree;

  const _AgreementActionButtons({
    required this.l10n,
    required this.isAccepted,
    required this.isSubmitting,
    required this.onAgree,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        label: l10n.agree,
        onPressed: (isAccepted && !isSubmitting) ? onAgree : null,
        isLoading: isSubmitting,
        variant: CustomButtonVariant.primary,
      ),
    );
  }
}
