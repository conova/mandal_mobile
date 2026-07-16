import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

/// Бондын дэлгэрэнгүйн нийтлэг толгой: нэр, дэд нэр, (арилжааны үед
/// бэлэн мөнгө), төлөв + зах зээлийн badge-ууд.
class BondDetailHeader extends StatelessWidget {
  final Map<String, dynamic>? bond;

  /// Арилжааны дизайнд нэрийн доор бэлэн мөнгө харуулна
  final bool showAvailableCash;

  const BondDetailHeader({
    super.key,
    required this.bond,
    this.showAvailableCash = false,
  });

  String _field(String key) => bond?[key]?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final title = bond == null
        ? 'Net Capital'
        : (bond!['STOCKNAME'] ?? bond!['COMPNAME'] ?? bond!['SYMBOL'])
                ?.toString() ??
            '';
    final subtitle = bond == null
        ? 'Нэт Капитал'
        : (bond!['COMPNAME2'] ?? bond!['TYPENAME'])?.toString() ?? '';

    final isForeign = _field('ISFOREIGN') == '1';
    final isOpen = _field('ISOPEN') == '1';
    final statusLabel = bond == null
        ? l10n.closed
        : (isForeign ? l10n.foreign : (isOpen ? l10n.open : l10n.closed));
    final marketLabel = bond == null
        ? l10n.primaryMarket
        : (_field('MARKET').toLowerCase() == 'primary'
            ? l10n.primaryMarket
            : l10n.secondaryMarket);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Урт нэрсийг таслахгүй — багтахгүй бол дараагийн мөрөнд бүтнээр
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                ),
              ),
          ],
        ),
        if (showAvailableCash) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.availableCash}: 10,000,000₮',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.primaryMain,
              fontWeight: AppTextStyles.bold,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBadge(
              statusLabel.toUpperCase(),
              extendedColors.primary100,
              extendedColors.primaryMain,
            ),
            _buildBadge(
              marketLabel.toUpperCase(),
              extendedColors.bgSecondary,
              theme.colorScheme.onSurface,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.paragraph1.copyWith(
          color: textColor,
          fontWeight: AppTextStyles.regular,
        ),
      ),
    );
  }
}
