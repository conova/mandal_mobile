import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import 'transaction_list_item.dart';

class TransactionFilterSheet extends StatefulWidget {
  final Set<FilterTag> initialSelectedTags;

  const TransactionFilterSheet({
    super.key,
    this.initialSelectedTags = const {},
  });

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late Set<FilterTag> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = Set.from(widget.initialSelectedTags);
  }

  void _toggle(FilterTag tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedTags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: extendedColors.neutral400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Cash section
          _buildSectionTitle(l10n.cashSection, theme, extendedColors),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(l10n.income, FilterTag.cashIncome, theme, extendedColors),
              _buildChip(l10n.expense, FilterTag.cashExpense, theme, extendedColors),
            ],
          ),
          const SizedBox(height: 20),
          // Bond section
          _buildSectionTitle(l10n.bonds, theme, extendedColors),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(l10n.boughtType, FilterTag.bondBought, theme, extendedColors),
              _buildChip(l10n.soldType, FilterTag.bondSold, theme, extendedColors),
              _buildChip(l10n.bondReturnType, FilterTag.bondReturn, theme, extendedColors),
            ],
          ),
          const SizedBox(height: 20),
          // Stock section
          _buildSectionTitle(l10n.stocks, theme, extendedColors),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(l10n.boughtType, FilterTag.stockBought, theme, extendedColors),
              _buildChip(l10n.soldType, FilterTag.stockSold, theme, extendedColors),
              _buildChip(l10n.dividendProfit, FilterTag.stockDividend, theme, extendedColors),
              _buildChip(l10n.stockTransferType, FilterTag.stockTransfer, theme, extendedColors),
            ],
          ),
          const SizedBox(height: 24),
          // Bottom buttons
          Divider(height: 1, color: extendedColors.neutral500),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _clearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: extendedColors.bgSecondary,
                      foregroundColor: extendedColors.neutral100,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.clearFilter,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedTags),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: extendedColors.primaryMain,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.filterAction,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme, ExtendedColors extendedColors) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: extendedColors.neutral100,
      ),
    );
  }

  Widget _buildChip(
    String label,
    FilterTag tag,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () => _toggle(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? extendedColors.primaryMain : extendedColors.bgBase,
          border: Border.all(
            color: isSelected ? extendedColors.primaryMain : extendedColors.neutral400,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : extendedColors.neutral100,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
