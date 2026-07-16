import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';

/// Бондын төлвийн тайлбарын bottom sheet — картуудын ⓘ icon дээр дарахад
/// гарна. Гарчиг/тайлбарыг [showForBond]-оор бондын төлвөөс автоматаар
/// сонгоно (нээлттэй / хаалттай / гадаад).
class BondStatusInfoSheet extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const BondStatusInfoSheet({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.info_outline,
  });

  /// Дурын гарчиг/тайлбар/icon-той мэдээллийн sheet нээнэ
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    IconData icon = Icons.info_outline,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BondStatusInfoSheet(
        title: title,
        description: description,
        icon: icon,
      ),
    );
  }

  /// Бондын ISOPEN/ISFOREIGN төлвөөс тохирох тайлбартай sheet нээнэ
  static Future<void> showForBond(
    BuildContext context, {
    required bool isOpen,
    required bool isForeign,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final String title;
    final String description;
    if (isForeign) {
      title = l10n.foreignBondInfoTitle;
      description = l10n.foreignBondInfoDesc;
    } else if (isOpen) {
      title = l10n.openBondInfoTitle;
      description = l10n.openBondInfoDesc;
    } else {
      title = l10n.closedBondInfoTitle;
      description = l10n.closedBondInfoDesc;
    }

    return show(context, title: title, description: description);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Чирэх бариул
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: extendedColors.neutral400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 40),
          // Дугуй дэвсгэртэй info icon
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: AppTextStyles.light,
              color: extendedColors.neutral200,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: l10n.close,
              variant: CustomButtonVariant.tertiary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
