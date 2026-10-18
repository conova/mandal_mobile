import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';

/// Гүйлгээний төрөл — орлого / зарлага
enum TxnDirection { income, expense }

/// Гүйлгээний ангилал
enum TxnCategory {
  /// Данс цэнэглэх, зарлага гаргах, хүүний орлого, ногдол ашгийн орлого
  cash,

  /// Хувьцаа авах / зарах
  stock,

  /// Бонд авах / зарах
  bond,
}

/// Хуулгын шүүлтүүр. Төрөл нь сонгосон бүх ангилалд нөлөөлнө
/// (жишээ: Орлого + Хувьцаа = хувьцаа зарсан). Хоосон бол бүгд.
class TransactionFilter {
  final Set<TxnDirection> directions;
  final Set<TxnCategory> categories;

  const TransactionFilter({
    this.directions = const {},
    this.categories = const {},
  });

  bool get isEmpty => directions.isEmpty && categories.isEmpty;

  /// Сонгогдсон зүйлсийн тоо — "Шүүлтүүр (N)" гэж харуулна
  int get count => directions.length + categories.length;

  bool hasDirection(TxnDirection d) => directions.isEmpty || directions.contains(d);
  bool hasCategory(TxnCategory c) => categories.isEmpty || categories.contains(c);
}

class TransactionFilterSheet extends StatefulWidget {
  final TransactionFilter initialFilter;

  const TransactionFilterSheet({
    super.key,
    this.initialFilter = const TransactionFilter(),
  });

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late Set<TxnDirection> _directions;
  late Set<TxnCategory> _categories;

  @override
  void initState() {
    super.initState();
    _directions = {...widget.initialFilter.directions};
    _categories = {...widget.initialFilter.categories};
  }

  void _toggle<T>(Set<T> set, T value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
  }

  void _apply() => Navigator.pop(
        context,
        TransactionFilter(directions: _directions, categories: _categories),
      );

  void _clear() => Navigator.pop(context, const TransactionFilter());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final count = _directions.length + _categories.length;
    final hasFilter = count > 0;

    // App-ын үндсэн шүүлтүүрийн загвар (захиалгын түүх, хугацаа сонгох
    // sheet-тэй ижил): drag handle, headlineSmall гарчиг, chip, доод 2 товч
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(color: extendedColors.bgBase),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: extendedColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(l10n.txnTypeSection, theme, extendedColors),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  label: '+ ${l10n.income}',
                  selected: _directions.contains(TxnDirection.income),
                  onTap: () => _toggle(_directions, TxnDirection.income),
                  theme: theme,
                  extendedColors: extendedColors,
                ),
                _chip(
                  label: '− ${l10n.expense}',
                  selected: _directions.contains(TxnDirection.expense),
                  onTap: () => _toggle(_directions, TxnDirection.expense),
                  theme: theme,
                  extendedColors: extendedColors,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle(l10n.txnCategorySection, theme, extendedColors),
            const SizedBox(height: 12),
            _categoryRow(
              icon: 'wallet-01',
              title: l10n.cash,
              subtitle: l10n.txnCategoryCashDesc,
              value: TxnCategory.cash,
              theme: theme,
              extendedColors: extendedColors,
            ),
            const SizedBox(height: 8),
            _categoryRow(
              icon: 'coins-swap-02',
              title: l10n.stockTradingCategory,
              value: TxnCategory.stock,
              theme: theme,
              extendedColors: extendedColors,
            ),
            const SizedBox(height: 8),
            _categoryRow(
              icon: 'bank',
              title: l10n.bondTrading,
              value: TxnCategory.bond,
              theme: theme,
              extendedColors: extendedColors,
            ),
            const SizedBox(height: 32),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _bottomButton(
                    label: hasFilter
                        ? '${l10n.clearFilter} ($count)'
                        : l10n.clearFilter,
                    background: hasFilter
                        ? extendedColors.primary100
                        : extendedColors.bgTertiary,
                    foreground: hasFilter
                        ? extendedColors.primaryMain
                        : extendedColors.neutral200,
                    onPressed: _clear,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bottomButton(
                    label: l10n.filterAction,
                    background: hasFilter
                        ? extendedColors.primaryMain
                        : extendedColors.bgTertiary,
                    foreground: hasFilter
                        ? extendedColors.bgBase
                        : extendedColors.neutral200,
                    onPressed: _apply,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) =>
      Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: extendedColors.neutral100,
        ),
      );

  /// Үндсэн шүүлтүүрийн chip — сонгогдсон бол хар дэвсгэр, цагаан текст
  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ThemeData theme,
    required ExtendedColors extendedColors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? extendedColors.neutral100 : extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppTextStyles.light,
            color: selected ? extendedColors.bgBase : extendedColors.neutral200,
          ),
        ),
      ),
    );
  }

  /// Ангиллын мөр — chip-тэй ижил өнгөний дүрэм (сонгогдсон бол хар дэвсгэр),
  /// зүүн талд icon, доор нь тайлбар
  Widget _categoryRow({
    required String icon,
    required String title,
    String? subtitle,
    required TxnCategory value,
    required ThemeData theme,
    required ExtendedColors extendedColors,
  }) {
    final selected = _categories.contains(value);
    final fg = selected ? extendedColors.bgBase : extendedColors.neutral100;
    return InkWell(
      onTap: () => _toggle(_categories, value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? extendedColors.neutral100 : extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CustomSvgIcon(icon, size: 22, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppTextStyles.regular,
                      color: fg,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: AppTextStyles.light,
                        color: selected
                            ? extendedColors.bgBase
                            : extendedColors.neutral200,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Цэвэрлэх" / "Шүүх" — үндсэн шүүлтүүрийн доод товчтой ижил
  Widget _bottomButton({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppTextStyles.regular,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
