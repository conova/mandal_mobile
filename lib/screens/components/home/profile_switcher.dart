import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/sub_account.dart';
import '../../../services/auth_service.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/initial_avatar.dart';

/// Home header-ийн зүүн талын профайл солигч — аватар + сум.
/// Дарахад өөрийн болон хүүхдийн данснуудын жагсаалт бүхий
/// bottom sheet нээгдэж, сонгосон данс руу шилжинэ.
class ProfileSwitcher extends StatelessWidget {
  const ProfileSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final auth = context.watch<AuthService>();

    final child = auth.activeSubAccount;
    final ownName = auth.custName ?? '';
    final initial = child?.initial ??
        (ownName.isNotEmpty ? ownName[0].toUpperCase() : '?');
    final color =
        child == null ? extendedColors.primaryMain : extendedColors.purple;

    return InkWell(
      onTap: () => _showSwitchSheet(context),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialAvatar(initial: initial, color: color, size: 32),
          const SizedBox(width: 2),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  /// switch_profile API дуудаж амжилттай бол sheet-ээ хаана
  Future<void> _switch(
    BuildContext ctx,
    AuthService auth,
    SubAccount? child,
  ) async {
    try {
      await auth.switchProfile(child);
      if (ctx.mounted) Navigator.pop(ctx);
    } catch (e) {
      if (ctx.mounted) CustomSnackbar.showError(ctx, e);
    }
  }

  void _showSwitchSheet(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final extendedColors = theme.extension<ExtendedColors>()!;
        final l10n = AppLocalizations.of(ctx)!;
        final auth = ctx.watch<AuthService>();
        final active = auth.activeSubAccount;
        final ownName = auth.custName ?? '';

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.disabledColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Данснууд олон үед sheet-ийн өндөрт багтаж scroll болно
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Өөрийн данс
                      _AccountRow(
                        initial: ownName.isNotEmpty
                            ? ownName[0].toUpperCase()
                            : '?',
                        color: extendedColors.primaryMain,
                        name: ownName,
                        isSelected: active == null,
                        onTap: () => _switch(ctx, auth, null),
                      ),
                      // Хүүхдийн данснууд
                      ...auth.subAccounts.map(
                        (child) => _AccountRow(
                          initial: child.initial,
                          color: extendedColors.purple,
                          name: child.nameOf(lang),
                          isSelected: active?.register == child.register,
                          onTap: () => _switch(ctx, auth, child),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Divider(height: 1, color: extendedColors.neutral500),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: l10n.back,
                    variant: CustomButtonVariant.tertiary,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Данс сонгох нэг мөр
class _AccountRow extends StatelessWidget {
  final String initial;
  final Color color;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountRow({
    required this.initial,
    required this.color,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            InitialAvatar(initial: initial, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: extendedColors.neutral100,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 26,
              color: isSelected
                  ? extendedColors.primaryMain
                  : extendedColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}
