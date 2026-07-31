import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order.dart';

class OrderDetailHeader extends StatelessWidget {
  final Order order;
  const OrderDetailHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    // Гарчиг: symbol (нэрээс ялгаатай бол), дэд гарчиг: нэр
    final title = order.symbol.isNotEmpty && order.symbol != order.name
        ? order.symbol
        : order.nameOf(lang);
    final subtitle = order.nameOf(lang);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != title) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Авах/Зарах
              _buildBadge(
                order.txnNameOf(lang).toUpperCase(),
                order.isBuy ? extendedColors.primary100 : extendedColors.red100,
                order.isBuy ? extendedColors.primaryMain : extendedColors.red,
                theme,
              ),
              const SizedBox(width: 8),
              // Нээлттэй/Хаалттай
              _buildBadge(
                (order.isOpen ? l10n.open : l10n.closed).toUpperCase(),
                extendedColors.bgSecondary,
                extendedColors.neutral100,
                theme,
              ),
              const SizedBox(width: 8),
              // Бонд/Хувьцаа
              _buildBadge(
                (order.isBond ? l10n.bond : l10n.stock).toUpperCase(),
                extendedColors.bgSecondary,
                extendedColors.neutral100,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    String label,
    Color bgColor,
    Color textColor,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
