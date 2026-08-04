import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import 'components/transaction_history/transaction_list_item.dart';
import 'components/transaction_history/transaction_filter_sheet.dart';
import 'components/transaction_history/transaction_period_sheet.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<FilterTag> _activeFilters = {FilterTag.nominal, FilterTag.csd};
  TimePeriod _timePeriod = TimePeriod.last1Year;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TransactionItem> _getMockTransactions() {
    return const [
      TransactionItem(
        title: 'Орлого - USD',
        date: '2025.08.20 18:23',
        amount: '250.00\$',
        isPositive: true,
        tag: FilterTag.cashIncome,
        currencyCode: 'USD',
      ),
      TransactionItem(
        title: 'Зарлага - USD',
        date: '2025.08.20 18:23',
        amount: '-100.00\$',
        isPositive: false,
        tag: FilterTag.cashExpense,
        currencyCode: 'USD',
      ),
      TransactionItem(
        title: 'Орлого - MNT',
        date: '2025.08.20 18:23',
        amount: '50,000.00₮',
        isPositive: true,
        tag: FilterTag.cashIncome,
        currencyCode: 'MNT',
      ),
      TransactionItem(
        title: 'Зарлага - MNT',
        date: '2025.08.20 18:23',
        amount: '-245,000.00₮',
        isPositive: false,
        tag: FilterTag.cashExpense,
        currencyCode: 'MNT',
      ),
      TransactionItem(
        title: 'Netcapital зарсан',
        date: '2025.08.20 18:23',
        amount: '-25,000,000₮',
        isPositive: false,
        tag: FilterTag.stockSold,
        currencyCode: 'MNT',
      ),
      TransactionItem(
        title: 'Lend.mn авсан',
        date: '2025.08.20 18:23',
        amount: '50,000,000.00₮',
        isPositive: true,
        tag: FilterTag.stockBought,
        currencyCode: 'MNT',
      ),
      TransactionItem(
        title: 'APU авсан',
        date: '2025.08.20 18:23',
        amount: '60,000,000.00₮',
        isPositive: true,
        tag: FilterTag.stockBought,
        currencyCode: 'MNT',
      ),
      TransactionItem(
        title: 'Simple өгөөж',
        date: '2025.08.20 18:23',
        amount: '3,000,000₮',
        isPositive: true,
        tag: FilterTag.bondReturn,
        currencyCode: 'MNT',
      ),
      TransactionItem(
        title: 'AARD зарсан',
        date: '2025.08.20 18:23',
        amount: '7,500,000.00₮',
        isPositive: true,
        tag: FilterTag.stockSold,
        currencyCode: 'MNT',
      ),
      TransactionItem(
        title: 'GLMT ногдол ашиг',
        date: '2025.08.20 18:23',
        amount: '1,000,000.00₮',
        isPositive: true,
        tag: FilterTag.stockDividend,
        currencyCode: 'MNT',
      ),
    ];
  }

  List<TransactionItem> _getFilteredTransactions(String? currencyFilter) {
    var transactions = _getMockTransactions();

    // Filter by tab (currency)
    if (currencyFilter == 'MNT') {
      transactions =
          transactions.where((t) => t.currencyCode == 'MNT').toList();
    } else if (currencyFilter == 'USD') {
      transactions =
          transactions.where((t) => t.currencyCode == 'USD').toList();
    }

    // Filter by active filter tags
    if (_activeFilters.isNotEmpty) {
      transactions =
          transactions.where((t) => _activeFilters.contains(t.tag)).toList();
    }

    return transactions;
  }

  String _getTimePeriodLabel(AppLocalizations l10n) {
    switch (_timePeriod) {
      case TimePeriod.last7Days:
        return l10n.last7Days;
      case TimePeriod.last1Month:
        return l10n.last1MonthFilter;
      case TimePeriod.last3Months:
        return l10n.last3Months;
      case TimePeriod.last6Months:
        return l10n.last6Months;
      case TimePeriod.last1Year:
        return l10n.last1Year;
      case TimePeriod.custom:
        if (_customStart != null && _customEnd != null) {
          return '${_customStart!.year.toString().padLeft(2, '0')}.${_customStart!.month.toString().padLeft(2, '0')}.${_customStart!.day.toString().padLeft(2, '0')} - ${_customEnd!.year.toString().padLeft(2, '0')}.${_customEnd!.month.toString().padLeft(2, '0')}.${_customEnd!.day.toString().padLeft(2, '0')}';
        }
        return l10n.selectDateRange;
    }
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<Set<FilterTag>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterSheet(
        initialSelectedTags: _activeFilters,
      ),
    );
    if (result != null) {
      setState(() {
        _activeFilters = result;
      });
    }
  }

  void _showPeriodSheet() async {
    final result = await showModalBottomSheet<PeriodResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionPeriodSheet(
        initialPeriod: _timePeriod,
        initialStartDate: _customStart,
        initialEndDate: _customEnd,
      ),
    );
    if (result != null) {
      setState(() {
        _timePeriod = result.period;
        _customStart = result.startDate;
        _customEnd = result.endDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and tabs
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Row(
                children: [
                  // Back button
                  CircleBackButton(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: extendedColors.neutral100,
                      indicatorColor: extendedColors.primaryMain,
                      indicatorWeight: 4,
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                      tabs: [
                        Tab(text: l10n.all),
                        Tab(text: l10n.tugrik),
                        Tab(text: l10n.dollar),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider below tabs
            Divider(height: 1, color: extendedColors.neutral500),
            // Filter chips row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: _activeFilters.isEmpty
                        ? l10n.filter
                        : '${l10n.filter} (${_activeFilters.length})',
                    extendedColors: extendedColors,
                    theme: theme,
                    onTap: _showFilterSheet,
                    isActive: _activeFilters.isNotEmpty,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: _getTimePeriodLabel(l10n),
                    extendedColors: extendedColors,
                    theme: theme,
                    onTap: _showPeriodSheet,
                    isActive: _timePeriod != TimePeriod.last1Year,
                  ),
                ],
              ),
            ),
            // Transaction list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionList(null),
                  _buildTransactionList('MNT'),
                  _buildTransactionList('USD'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required ExtendedColors extendedColors,
    required ThemeData theme,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          color: isActive
              ? extendedColors.primaryMain
              : extendedColors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isActive ? extendedColors.bgBase : extendedColors.neutral100,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            CustomSvgIcon(
              'button-down',
              size: 6,
              color: isActive ? extendedColors.bgBase : extendedColors.neutral200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(String? currencyFilter) {
    final transactions = _getFilteredTransactions(currencyFilter);

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          '-',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).extension<ExtendedColors>()!.neutral300,
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length + 1, // +1 for loading indicator
      itemBuilder: (context, index) {
        if (index == transactions.length) {
          // Loading indicator at bottom
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context)
                      .extension<ExtendedColors>()!
                      .primaryMain,
                ),
              ),
            ),
          );
        }
        return TransactionListItem(transaction: transactions[index]);
      },
    );
  }
}
