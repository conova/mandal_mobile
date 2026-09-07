import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';
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
  Set<FilterTag> _activeFilters = {};
  TimePeriod _timePeriod = TimePeriod.last1Year;
  DateTime? _customStart;
  DateTime? _customEnd;

  bool _isLoading = true;
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Таб солиход curCode шүүлтээр дахин татна
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _fetch();
    });
    Future.microtask(_fetch);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Шүүлтүүд → /account/statement параметрүүд ───
  // Бүлэг доторх сонголт ганц бол тухайн утга, олон/хоосон бол '' (бүгд)

  String _pickOne(Map<FilterTag, String> mapping) {
    final selected = mapping.keys.where(_activeFilters.contains).toList();
    return selected.length == 1 ? mapping[selected.first]! : '';
  }

  String get _acntTypeParam => _pickOne({
        FilterTag.nominal: 'nominal',
        FilterTag.csd: 'mcsd',
      });

  String get _cashTypeParam => _pickOne({
        FilterTag.cashIncome: '0',
        FilterTag.cashExpense: '1',
      });

  String get _bondParam => _pickOne({
        FilterTag.bondBought: '0',
        FilterTag.bondSold: '1',
        FilterTag.bondReturn: 'B',
      });

  String get _stocksParam => _pickOne({
        FilterTag.stockBought: '0',
        FilterTag.stockSold: '1',
        FilterTag.stockDividend: 'D',
        FilterTag.stockTransfer: 'S',
      });

  String get _curCodeParam => switch (_tabController.index) {
        1 => 'MNT',
        2 => 'USD',
        _ => '',
      };

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}';

  /// Сонгосон интервалын эхлэх/дуусах огноо (дуусах нь өнөөдөр,
  /// custom-оос бусад)
  (DateTime, DateTime) _dateRange() {
    final now = DateTime.now();
    return switch (_timePeriod) {
      TimePeriod.last7Days => (now.subtract(const Duration(days: 7)), now),
      TimePeriod.last1Month =>
          (DateTime(now.year, now.month - 1, now.day), now),
      TimePeriod.last3Months =>
          (DateTime(now.year, now.month - 3, now.day), now),
      TimePeriod.last6Months =>
          (DateTime(now.year, now.month - 6, now.day), now),
      TimePeriod.last1Year => (DateTime(now.year - 1, now.month, now.day), now),
      TimePeriod.custom => (
          _customStart ?? DateTime(now.year - 1, now.month, now.day),
          _customEnd ?? now,
        ),
    };
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _rows = const [];
    });
    try {
      final (start, end) = _dateRange();
      final rows = await context.read<AuthService>().getAccountStatement(
            acntType: _acntTypeParam,
            cashType: _cashTypeParam,
            bond: _bondParam,
            stocks: _stocksParam,
            curCode: _curCodeParam,
            start: _fmt(start),
            end: _fmt(end),
          );
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  // ─── Мөр → жагсаалтын item ───

  /// Хоёр хэлт талбараас locale-д тохирохыг сонгоно (хоосон бол нөгөөг)
  String _pickLang(Map<String, dynamic> row, String mn, String en, bool isEn) {
    final first = (isEn ? row[en] : row[mn])?.toString() ?? '';
    if (first.isNotEmpty) return first;
    return (isEn ? row[mn] : row[en])?.toString() ?? '';
  }

  /// "2025/04/24 08:44:37" → "2025.04.24 08:44"
  String _formatRegDate(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '';
    final normalized = s.replaceAll('/', '.').replaceAll('-', '.');
    return normalized.length >= 16 ? normalized.substring(0, 16) : normalized;
  }

  /// Гүйлгээний төрлөөс icon-д хэрэглэх tag тааруулна
  FilterTag _tagOf(Map<String, dynamic> row) {
    final t = '${row['TXNTYPE'] ?? ''} ${row['TXNTYPE2'] ?? ''}'.toLowerCase();
    if (t.contains('ногдол') || t.contains('dividend')) {
      return FilterTag.stockDividend;
    }
    if (t.contains('өгөөж') || t.contains('coupon')) return FilterTag.bondReturn;
    if (t.contains('орлого') || t.contains('income') || t.contains('deposit')) {
      return FilterTag.cashIncome;
    }
    if (t.contains('зарлага') ||
        t.contains('expense') ||
        t.contains('withdraw')) {
      return FilterTag.cashExpense;
    }
    if (t.contains('зар') || t.contains('sell') || t.contains('sold')) {
      return FilterTag.stockSold;
    }
    return FilterTag.stockBought;
  }

  TransactionItem _itemFromRow(Map<String, dynamic> row, bool isEn) {
    final curCode = row['CURCODE']?.toString() ?? 'MNT';
    final isUsd = curCode == 'USD';
    final amount = num.tryParse(
          row['AMOUNT']?.toString().replaceAll(',', '') ?? '',
        ) ??
        0;
    final txnType = _pickLang(row, 'TXNTYPE', 'TXNTYPE2', isEn);
    final title = txnType.isNotEmpty
        ? '$txnType - $curCode'
        : _pickLang(row, 'TXNNAME', 'TXNNAME2', isEn);

    return TransactionItem(
      title: title,
      date: _formatRegDate(row['REGDATE']),
      amount: formatStockAmount(amount, isForeign: isUsd),
      isPositive: amount > 0,
      tag: _tagOf(row),
      currencyCode: curCode,
    );
  }

  List<TransactionItem> _itemsFor(String? currencyFilter) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    var rows = _rows;
    if (currencyFilter != null) {
      rows = rows
          .where((r) => (r['CURCODE']?.toString() ?? 'MNT') == currencyFilter)
          .toList();
    }
    return rows.map((r) => _itemFromRow(r, isEn)).toList();
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
      _fetch();
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
      _fetch();
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
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;

    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: extendedColors.primaryMain,
          ),
        ),
      );
    }

    final transactions = _itemsFor(currencyFilter);

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          '-',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: extendedColors.neutral300,
              ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      color: extendedColors.primaryMain,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return TransactionListItem(transaction: transactions[index]);
        },
      ),
    );
  }
}
