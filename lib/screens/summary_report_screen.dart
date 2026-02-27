import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/finance_chart.dart';
import '../widgets/summary_table_row.dart';
import '../widgets/custom_button.dart';

class SummaryReportScreen extends StatelessWidget {
  const SummaryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(l10n.summaryReport),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalAssets,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '50,628,000',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      '.21₮',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '+210,351.52₮',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.primaryMain,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 12, color: theme.dividerColor),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_drop_up,
                      color: extendedColors.primaryMain,
                      size: 20,
                    ),
                    Text(
                      '9.71%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.primaryMain,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${l10n.lastMonth})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const FinanceChart(),
                const SizedBox(height: 16),
                _buildTimeFilters(l10n, theme, extendedColors),
                const SizedBox(height: 32),
                _buildAssetTable(l10n, theme),
                const SizedBox(height: 32),
                _buildCashFlowSection(l10n, theme),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: CustomButton(
              label: l10n.downloadReport,
              onPressed: () {},
              variant: CustomButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilters(
    AppLocalizations l10n,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final filters = [
      l10n.oneDay,
      l10n.threeDays,
      l10n.sixDays,
      l10n.oneYear,
      l10n.all,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: filters.map((f) {
        bool isSelected = f == l10n.oneDay;
        return Text(
          f,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onSurface
                : extendedColors.neutral500,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssetTable(AppLocalizations l10n, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SummaryTableRow(
            label: l10n.type,
            val1: '2025.10.28',
            val2: '2025.11.27',
            isHeader: true,
          ),
          SummaryTableRow(
            label: l10n.totalAssets,
            val1: '50,000,000₮',
            val2: '1,000,000,000₮',
          ),
          SummaryTableRow(
            label: l10n.cash,
            val1: '5,000,000₮',
            val2: '5,000,000₮',
          ),
          SummaryTableRow(
            label: l10n.stocks,
            val1: '40,000,000₮',
            val2: '40,000,000₮',
          ),
          SummaryTableRow(
            label: l10n.bonds,
            val1: '5,000,000₮',
            val2: '5,000,000₮',
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowSection(AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        SummaryTableRow(
          label: l10n.incomeExpense,
          val1: l10n.selectedPeriod,
          isHeader: true,
        ),
        SummaryTableRow(label: l10n.incomeSalary, val1: '1,000,000₮'),
        SummaryTableRow(label: l10n.stockProfit, val1: '1,000,000₮'),
        SummaryTableRow(label: l10n.interestIncome, val1: '100,000₮'),
        SummaryTableRow(label: l10n.bondPrincipal, val1: '50,000,000₮'),
        SummaryTableRow(label: l10n.dividendProfit, val1: '100,000₮'),
      ],
    );
  }
}
