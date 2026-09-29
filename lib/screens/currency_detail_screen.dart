import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/widgets/circle_back_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_info_popup_bottom_sheet.dart';
import '../widgets/release_locked_amount_sheet.dart';
import 'components/transaction_history/transaction_list_item.dart';
import 'components/transaction_history/transaction_skeleton_loader.dart';

enum CurrencyType { mnt, usd }

class CurrencyDetailScreen extends StatefulWidget {
  const CurrencyDetailScreen({super.key});

  @override
  State<CurrencyDetailScreen> createState() => _CurrencyDetailScreenState();
}

class _CurrencyDetailScreenState extends State<CurrencyDetailScreen> {
  double _availableCash = 0;
  double _lockedAmount = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _historyRows = [];
  bool _isHistoryLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(_fetchData);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if (offset > 50 && !_showStickyHeader) {
      setState(() => _showStickyHeader = true);
    } else if (offset <= 50 && _showStickyHeader) {
      setState(() => _showStickyHeader = false);
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    final typeArg = args is Map ? args['type']?.toString() : args as String?;
    final isMnt = typeArg != 'usd' && typeArg != 'dollar';

    setState(() {
      _isLoading = true;
      _isHistoryLoading = true;
    });

    try {
      final auth = context.read<AuthService>();
      
      // Fetch Balance Data
      if (isMnt) {
        final summary = await auth.getPortfolioSummary();
        if (mounted) {
          setState(() {
            _availableCash = summary.cashBalance - summary.holdAmount;
            _lockedAmount = summary.holdAmount;
            _isLoading = false;
          });
        }
      } else {
        final breakdown = await auth.getAssetBreakdown();
        final usdItem = breakdown.firstWhere(
          (item) => item['type'] == 'usd' || item['type'] == 'dollar',
          orElse: () => <String, dynamic>{},
        );
        if (mounted) {
          setState(() {
            _availableCash = (usdItem['amount'] as num?)?.toDouble() ?? 0;
            // USD-ийн хувьд түгжигдсэн дүн одоогоор breakdown-д байхгүй бол 0
            _lockedAmount = 0;
            _isLoading = false;
          });
        }
      }

      // Fetch Transaction History (Last 1 year)
      final now = DateTime.now();
      final start = DateTime(now.year - 1, now.month, now.day);
      String fmt(DateTime d) =>
          '${d.year.toString().padLeft(4, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.day.toString().padLeft(2, '0')}';

      final rows = await auth.getAccountStatement(
        curCode: isMnt ? 'MNT' : 'USD',
        cashType: '0,1',
        start: fmt(start),
        end: fmt(now),
      );

      if (mounted) {
        rows.sort((a, b) {
          final dateA = a['REGDATE']?.toString() ?? '';
          final dateB = b['REGDATE']?.toString() ?? '';
          return dateB.compareTo(dateA);
        });

        setState(() {
          _historyRows = rows;
          _isHistoryLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching currency data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isHistoryLoading = false;
        });
      }
    }
  }

  String _pickLang(Map<String, dynamic> row, String mn, String en, bool isEn) {
    final first = (isEn ? row[en] : row[mn])?.toString() ?? '';
    if (first.isNotEmpty) return first;
    return (isEn ? row[mn] : row[en])?.toString() ?? '';
  }

  String _formatRegDate(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '';
    final normalized = s.replaceAll('/', '.').replaceAll('-', '.');
    return normalized.length >= 16 ? normalized.substring(0, 16) : normalized;
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final topPadding = MediaQuery.paddingOf(context).top;
    final args = ModalRoute.of(context)?.settings.arguments;
    // Хуучин String args болон шинэ {'type', 'amount'} Map хоёуланг дэмжинэ
    final typeArg = args is Map ? args['type']?.toString() : args as String?;
    final headerAmount = args is Map ? (args['amount'] as num?)?.toDouble() : null;
    final currencyType =
        typeArg == 'usd' || typeArg == 'dollar'
            ? CurrencyType.usd
            : CurrencyType.mnt;

    final isMnt = currencyType == CurrencyType.mnt;
    final accentColor = isMnt ? extendedColors.primaryMain : extendedColors.neutral100;
    final currencySymbol = isMnt ? '₮' : '\$';
    final title = isMnt ? l10n.tugrik : l10n.dollar;

    // Нийт дүн
    final displayTotal = _isLoading && headerAmount != null && _availableCash == 0
        ? headerAmount
        : (isMnt ? (_availableCash + _lockedAmount) : _availableCash);

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient
                _buildHeader(
                  context: context,
                  theme: theme,
                  extendedColors: extendedColors,
                  accentColor: accentColor,
                  title: title,
                  amount: formatStockAmount(displayTotal, isForeign: !isMnt),
                  currencySymbol: currencySymbol,
                  isMnt: isMnt,
                ),
                const SizedBox(height: 24),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: l10n.income,
                          size: CustomButtonSize.small,
                          icon: CustomSvgIcon('plus'),
                          variant: isMnt ? CustomButtonVariant.primary : CustomButtonVariant.neutral,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/income_method'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          label: l10n.expense,
                          size: CustomButtonSize.small,
                          icon: CustomSvgIcon('reverse-right'),
                          variant: CustomButtonVariant.tertiary,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/withdraw_method'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: extendedColors.neutral500),
                const SizedBox(height: 16),
                // General Info section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.generalInfo,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  context: context,
                  theme: theme,
                  extendedColors: extendedColors,
                  icon: 'coins-hand',
                  label: l10n.availableCash,
                  amount: formatStockAmount(_availableCash, isForeign: !isMnt),
                  l10n: l10n,
                  descTitle: l10n.cash,
                  descText: l10n.cashDesc
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  context: context,
                  theme: theme,
                  extendedColors: extendedColors,
                  icon: 'file-check-02',
                  label: l10n.lockedAmountLabel,
                  amount: formatStockAmount(_lockedAmount, isForeign: !isMnt),
                  trailing: isMnt
                      ? CustomButton(
                          label: l10n.release,
                          size: CustomButtonSize.small,
                          minWidth: 78,
                          variant: CustomButtonVariant.tertiary,
                          onPressed: () async {
                            await ReleaseLockedAmountSheet.show(context);
                            _fetchData();
                          },
                        )
                      : null,
                  l10n: l10n,
                  descTitle: l10n.holdAmount,
                  descText: l10n.holdAmountDesc
                ),
                const SizedBox(height: 24),
                Divider(height: 1, color: extendedColors.neutral500),
                const SizedBox(height: 24),
                // History section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.history,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                ..._buildTransactionHistory(
                  theme: theme,
                  extendedColors: extendedColors,
                  l10n: l10n,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            top: topPadding + 20,
            left: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _showStickyHeader
                    ? [
                        BoxShadow(
                          color: extendedColors.neutral100.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: const CircleBackButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required Color accentColor,
    required String title,
    required String amount,
    required String currencySymbol,
    required bool isMnt,
  }) {
    final gradientColors = isMnt
        ? [extendedColors.primary200, extendedColors.bgBase]
        : [extendedColors.bgTertiary, extendedColors.bgBase];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              // Icon мөрийн голд (Back товч Positioned-оор Stack-д байгаа)
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: CustomSvgIcon(
                      isMnt ? 'tugrug-01' : 'currency-dollar',
                      size: 22,
                      color: extendedColors.bgBase,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 8),
            _buildAmountText(amount, theme, extendedColors),
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountText(String amount, ThemeData theme, ExtendedColors extendedColors) {
    // Split amount into integer and decimal parts
    final dotIndex = amount.indexOf('.');
    if (dotIndex == -1) {
      return Text(
        amount,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: extendedColors.neutral100,
        ),
      );
    }

    final integerPart = amount.substring(0, dotIndex);
    final decimalPart = amount.substring(dotIndex);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: integerPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          TextSpan(
            text: decimalPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required String icon,
    required String label,
    required String amount,
    required AppLocalizations l10n,
    required dynamic descTitle,
    required dynamic descText,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: CustomSvgIcon(icon, color: extendedColors.neutral100, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomInfoPopupBottomSheet(
                      title: descTitle,
                      description: descText,
                      extendedColors: extendedColors,
                      l10n: l10n,
                      icon: icon,
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  List<Widget> _buildTransactionHistory({
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required AppLocalizations l10n,
  }) {
    if (_isHistoryLoading) {
      return [
        const TransactionSkeletonLoader(
          itemCount: 3,
          shrinkWrap: true,
        ),
      ];
    }

    if (_historyRows.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Center(
            child: Text(
              textAlign: TextAlign.center,
              l10n.noCashStatementYet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral100,
              ),
            ),
          ),
        )
      ];
    }

    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return _historyRows.map((row) {
      final curCode = row['CURCODE']?.toString() ?? 'MNT';
      final isUsd = curCode == 'USD';
      final amountNum = num.tryParse(
            row['AMOUNT']?.toString().replaceAll(',', '') ?? '',
          ) ??
          0;
      final txnType = _pickLang(row, 'TXNTYPE', 'TXNTYPE2', isEn);
      final compName = _pickLang(row, 'COMPNAME', 'COMPNAME2', isEn);
      final stockSymbol = row['SYMBOL']?.toString() ?? '';
      final tag = _tagOf(row);

      final title = txnType.isNotEmpty
          ? (tag == FilterTag.stockDividend || tag == FilterTag.stockBought || tag == FilterTag.stockSold)
              ? '$stockSymbol $txnType'
              : (tag == FilterTag.bondBought || tag == FilterTag.bondSold || tag == FilterTag.bondReturn)
                  ? '$compName $txnType'
                  : '$txnType - $curCode'
          : _pickLang(row, 'TXNNAME', 'TXNNAME2', isEn);

      final isPositive = tag == FilterTag.cashIncome || tag == FilterTag.stockSold ||tag == FilterTag.bondReturn || tag == FilterTag.bondSold;
      final statusCode = row['STATUS']?.toString() ?? '';
      // status code == 0 "Cancelled cash"
      // status code == 2 "Waiting cash"
      // status code == 1 "Completed cash"
      // status code == 3 "Unsuccessful cash"
      
      // Use TransactionListItem style but as a simple Row to match screen's current padding/feel
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            _buildHistoryIcon(tag, row['STATUS']?.toString() ?? '', isPositive, curCode, extendedColors),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatRegDate(row['REGDATE']),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  isPositive ? formatStockAmount(amountNum.abs(), isForeign: isUsd) : '-${formatStockAmount(amountNum.abs(), isForeign: isUsd)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: statusCode == '0' || statusCode == '3'
                        ? extendedColors.red
                        : statusCode == '2'
                        ? extendedColors.yellow
                        : isPositive ? extendedColors.primaryMain : extendedColors.neutral100,
                  ),
                ),
                if(statusCode == '0' || statusCode == '3' || statusCode == '2')
                  Text(
                    statusCode == '0' || statusCode == '3' ? l10n.cancelled : l10n.waiting,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: statusCode == '0' || statusCode == '3'
                          ? extendedColors.red
                          : extendedColors.yellow
                    ),
                  )
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildHistoryIcon(FilterTag tag, String statusCode, bool isPositive, String curCode, ExtendedColors extendedColors) {
    final isCash = tag == FilterTag.cashIncome || tag == FilterTag.cashExpense;
    final isBond = tag == FilterTag.bondBought || tag == FilterTag.bondSold || tag == FilterTag.bondReturn;

    Color bgColor = statusCode == '0' || statusCode == '3'
        ? extendedColors.red200
        : statusCode == '2'
            ? extendedColors.yellow200
            : isPositive ? extendedColors.primary100 : extendedColors.bgSecondary;

    Widget iconContent;
    if (isCash) {
      iconContent = CustomSvgIcon(
        (curCode == 'USD') ? 'currency-dollar' : 'tugrug-01',
        color: statusCode == '0' || statusCode == '3'
            ? extendedColors.red
            : statusCode == '2'
            ? extendedColors.yellow
            : isPositive ? extendedColors.primaryMain : extendedColors.neutral300,
        size: 22,
      );
    } else if (isBond) {
      iconContent = CustomSvgIcon(
        'bank-note-01',
        color: statusCode == '0' || statusCode == '3'
            ? extendedColors.red
            : statusCode == '2'
            ? extendedColors.yellow
            : isPositive ? extendedColors.primaryMain : extendedColors.neutral300,
        size: 22,
      );
    } else {
      iconContent = CustomSvgIcon(
        'coins-swap-02',
        color: statusCode == '0' || statusCode == '3'
            ? extendedColors.red
            : statusCode == '2'
            ? extendedColors.yellow
            : isPositive ? extendedColors.primaryMain : extendedColors.neutral300,
        size: 22,
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: iconContent),
    );
  }
}
