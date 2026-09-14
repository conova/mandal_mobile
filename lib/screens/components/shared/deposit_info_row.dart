import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/custom_svg_icon.dart';

/// Шилжүүлгийн мэдээллийн нэг мөр — шошго, утга, баруун талд хуулах товч
/// (эсвэл [trailing] өгвөл түүнийг, жнь банкны лого).
///
/// Бондын болон долларын данс цэнэглэх дэлгэцүүд хуваалцана.
class DepositInfoRow extends StatelessWidget {
  final String label;
  final String value;

  /// Хуулах утга — дэлгэц дээрх бичиглэлээс ялгаатай байж болно
  /// (жнь IBAN-г зайгүйгээр хуулна)
  final String? copyValue;
  final Widget? trailing;
  final bool isLast;

  const DepositInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.copyValue,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: EdgeInsets.only(top: 14, bottom: isLast ? 14 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (trailing != null)
            trailing!
          else if (copyValue != null && copyValue!.isNotEmpty)
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyValue!));
                CustomSnackbar.show(context, message: l10n.copiedLabel);
              },
              icon: CustomSvgIcon(
                'copy-06',
                size: 24,
                color: extendedColors.primaryMain,
              ),
            ),
        ],
      ),
    );
  }
}
