import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../models/summary_report_data.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/finance_chart.dart';
import '../widgets/summary_table_row.dart';
import '../widgets/custom_button.dart';

/// Хугацааны шүүлтүүрүүд — сонголт бүр өөр start огноотой
enum _Period { oneMonth, threeMonths, sixMonths, oneYear, all }

class SummaryReportScreen extends StatefulWidget {
  const SummaryReportScreen({super.key});

  @override
  State<SummaryReportScreen> createState() => _SummaryReportScreenState();
}

class _SummaryReportScreenState extends State<SummaryReportScreen> {
  _Period _period = _Period.all;
  bool _isLoading = true;

  SummaryReportData _report = SummaryReportData.empty;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetch);
  }

  String _formatQueryDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _formatQueryDateDot(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// Сонгосон шүүлтүүрийн эхлэх огноо
  DateTime _startDate() {
    final now = DateTime.now();
    switch (_period) {
      case _Period.oneMonth:
        return DateTime(now.year, now.month - 1, now.day);
      case _Period.threeMonths:
        return DateTime(now.year, now.month - 3, now.day);
      case _Period.sixMonths:
        return DateTime(now.year, now.month - 6, now.day);
      case _Period.oneYear:
        return DateTime(now.year - 1, now.month, now.day);
      case _Period.all:
        return DateTime(2000, 1, 1);
    }
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final data = await context.read<AuthService>().getSummaryReport(
        start: _formatQueryDate(_startDate()),
        end: _formatQueryDate(DateTime.now()),
      );
      if (!mounted) return;
      setState(() {
        _report = SummaryReportData.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  void _onPeriodSelected(_Period period) {
    if (period == _period) return;
    setState(() => _period = period);
    _fetch();
  }

  // ── Тайлан татах ───────────────────────────────────────────────────────

  /// Хугацаа сонгох bottom sheet нээж, сонгосон хугацааны тайланг
  /// PDF болгож татна.
  Future<void> _showDownloadSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final options = <(_Period, String)>[
      (_Period.oneMonth, l10n.periodOneMonth),
      (_Period.threeMonths, l10n.periodThreeMonths),
      (_Period.sixMonths, l10n.periodSixMonths),
      (_Period.oneYear, l10n.periodTwelveMonths),
      (_Period.all, l10n.allTimeReport),
    ];

    final selected = await showModalBottomSheet<_Period>(
      context: context,
      backgroundColor: extendedColors.bgBase,
      builder: (sheetContext) {
        var current = _period;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) => SafeArea(
            // Намхан дэлгэцэд багтахгүй бол scroll хийгдэнэ (overflow-гүй)
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Чирэх бариул
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: extendedColors.neutral300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.reportPeriodTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final option in options)
                    InkWell(
                      onTap: () => setSheetState(() => current = option.$1),
                      child: Container(
                        color: current == option.$1
                            ? extendedColors.primary100
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.$2,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: extendedColors.neutral100,
                                ),
                              ),
                            ),
                            _buildRadio(current == option.$1, extendedColors),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: l10n.downloadReport,
                        onPressed: () => Navigator.pop(sheetContext, current),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    // Сонгосон хугацаа өөр бол эхлээд датаг шинэчилнэ
    if (selected != _period) {
      setState(() => _period = selected);
      await _fetch();
      if (!mounted) return;
    }
    await _downloadPdf();
  }

  Widget _buildRadio(bool selected, ExtendedColors extendedColors) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? extendedColors.primaryMain
              : extendedColors.neutral400,
          width: selected ? 7 : 2,
        ),
        color: extendedColors.bgBase,
      ),
    );
  }

  /// Дэлгэцийн мэдээллийг PDF болгож share/татах цонх нээнэ
  Future<void> _downloadPdf() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Кирилл дэмждэг фонт (Roboto)
      final font = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();

      final dates = _dates;
      final latestTotal = dates.isEmpty ? 0.0 : _totalOf(dates.last);
      final start = _formatQueryDate(_startDate());
      final end = _formatQueryDate(DateTime.now());

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                l10n.summaryReport,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '$start - $end',
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '${l10n.totalAssets}: ${_money(latestTotal)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              if (dates.isNotEmpty)
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headers: [
                    l10n.type,
                    dates.first,
                    if (dates.length > 1) dates.last,
                  ],
                  data: [
                    [
                      l10n.totalAssets,
                      _money(_totalOf(dates.first)),
                      if (dates.length > 1) _money(_totalOf(dates.last)),
                    ],
                    [
                      l10n.cash,
                      _money(_typeOf(dates.first, 'cash')),
                      if (dates.length > 1) _money(_typeOf(dates.last, 'cash')),
                    ],
                    [
                      l10n.stocks,
                      _money(_typeOf(dates.first, 'stock')),
                      if (dates.length > 1)
                        _money(_typeOf(dates.last, 'stock')),
                    ],
                    [
                      l10n.bonds,
                      _money(_typeOf(dates.first, 'bond')),
                      if (dates.length > 1) _money(_typeOf(dates.last, 'bond')),
                    ],
                  ],
                ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: [l10n.incomeExpense, l10n.selectedPeriod],
                data: [
                  [l10n.incomeSalary, _money(_txnAmount('cash'))],
                  [l10n.stockProfit, _money(_txnAmount('stock'))],
                  [l10n.interestIncome, _money(_txnAmount('rateincome'))],
                  [l10n.bondPrincipal, _money(_txnAmount('bond'))],
                  [l10n.dividendProfit, _money(_txnAmount('dividend'))],
                ],
              ),
            ],
          ),
        ),
      );

      final bytes = await doc.save();
      await Printing.sharePdf(bytes: bytes, filename: 'summary_report.pdf');
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
    }
  }

  // ── Model руу дамжуулсан богино нэрс ──────────────────────────────────

  List<String> get _dates => _report.dates;
  double _totalOf(String date) => _report.totalOf(date);
  double _typeOf(String date, String type) => _report.typeOf(date, type);
  double _txnAmount(String type) => _report.txnAmount(type);

  String _money(double v) => formatStockAmount(v, decimals: 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final dates = _dates;
    final latestTotal = dates.isEmpty ? 0.0 : _totalOf(dates.last);
    final earliestTotal = dates.isEmpty ? 0.0 : _totalOf(dates.first);
    final diff = latestTotal - earliestTotal;
    final pct = earliestTotal == 0 ? 0.0 : diff / earliestTotal * 100;
    final isPositive = diff >= 0;
    final changeColor = isPositive
        ? extendedColors.primaryMain
        : extendedColors.red;

    // График — огноо тус бүрийн нийт хөрөнгө.
    // X тэнхлэг: 1 өдөр = 1 нэгж (эхний огнооноос хойших хоног)
    final firstDate = dates.isEmpty ? null : parseStockDate(dates.first);
    final spots = <FlSpot>[
      for (var i = 0; i < dates.length; i++)
        FlSpot(
          firstDate == null
              ? i.toDouble()
              : (parseStockDate(dates[i])?.difference(firstDate).inDays ?? i)
                    .toDouble(),
          _totalOf(dates[i]),
        ),
    ];

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            l10n.summaryReport,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral100,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircleBackButton(),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading && _report.isEmpty)
            const Center(child: CircularProgressIndicator())
          // Portfolio дата хоосон — "тайлан үүсээгүй" төлөв
          else if (_report.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/box.png',
                    width: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.folder_open_outlined,
                      size: 96,
                      color: extendedColors.neutral400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noReportYet,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            )
          else
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
                      color: extendedColors.neutral100,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildTotalAmount(latestTotal, theme, extendedColors),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${isPositive ? '+' : ''}${_money(diff)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 12,
                        color: theme.dividerColor,
                      ),
                      const SizedBox(width: 8),
                      CustomSvgIcon(
                        isPositive
                            ? 'button-up'
                            : 'button-down',
                        color: changeColor,
                        size: 6,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pct.abs().toStringAsFixed(2)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: changeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '(${l10n.selectedPeriod})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: FontWeight.w300,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FinanceChart(spots: spots, startDate: firstDate),
                  const SizedBox(height: 16),
                  _buildTimeFilters(l10n, theme, extendedColors),
                  const SizedBox(height: 32),
                  _buildAssetTable(l10n, theme, dates),
                  const SizedBox(height: 36),
                  Divider(height: 1, color: extendedColors.neutral500,),
                  const SizedBox(height: 36),
                  _buildCashFlowSection(l10n, theme),
                ],
              ),
            ),
          // Дата байхгүй үед татах товч харуулахгүй
          /*if (!_report.isEmpty) ...[
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Container(
                decoration: BoxDecoration(
                    color: extendedColors.bgBase
                ),
                child: CustomButton(
                  label: l10n.downloadReport,
                  onPressed: _showDownloadSheet,
                  variant: CustomButtonVariant.primary,
                ),
              ),
            ),
          ]*/
        ],
      ),
      bottomNavigationBar: !_report.isEmpty
        ? Container(
            padding: EdgeInsets.only(bottom: 24, left: 20, right: 20, top: 10),
            decoration: BoxDecoration(
                color: extendedColors.bgBase,
                border: BorderDirectional(top: BorderSide(color: extendedColors.neutral500, width: 1)),
            ),
            child: CustomButton(
              label: l10n.downloadReport,
              onPressed: _showDownloadSheet,
              variant: CustomButtonVariant.primary,
            ),
          )
        : Container(height: 0,)
    );
  }

  /// Нийт хөрөнгө — бүхэл хэсэг том, бутархай нь бүдэг
  Widget _buildTotalAmount(
    double total,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final formatted = formatStockAmount(total, decimals: 2);
    final dotIdx = formatted.indexOf('.');
    final whole = dotIdx == -1 ? formatted : formatted.substring(0, dotIdx);
    final fraction = dotIdx == -1 ? '' : formatted.substring(dotIdx);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            whole,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (fraction.isNotEmpty)
          Text(
            fraction,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral300,
            ),
          ),
      ],
    );
  }

  Widget _buildTimeFilters(
    AppLocalizations l10n,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final filters = <(_Period, String)>[
      (_Period.oneMonth, l10n.m1),
      (_Period.threeMonths, l10n.m3),
      (_Period.sixMonths, l10n.m6),
      (_Period.oneYear, l10n.y1),
      (_Period.all, l10n.all),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: filters.map((f) {
        final isSelected = f.$1 == _period;
        return GestureDetector(
          onTap: () => _onPeriodSelected(f.$1),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              f.$2,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : extendedColors.neutral300,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Хөрөнгийн хүснэгт — эхний ба сүүлийн огнооны багануудтай.
  /// Нэг л огноотой бол ганц баганаар харуулна.
  Widget _buildAssetTable(
    AppLocalizations l10n,
    ThemeData theme,
    List<String> dates,
  ) {
    if (dates.isEmpty) {
      return const SizedBox.shrink();
    }
    final first = dates.first;
    final last = dates.last;
    final hasTwo = dates.length > 1;

    String col2(String type) => hasTwo
        ? (type == 'total'
              ? _money(_totalOf(last))
              : _money(_typeOf(last, type)))
        : '';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SummaryTableRow(
            label: l10n.type,
            val1: first,
            val2: hasTwo ? last : '',
            isOdd: true,
          ),
          SummaryTableRow(
            label: l10n.cash,
            val1: _money(_typeOf(first, 'cash')),
            val2: col2('cash'),
            isOdd: false,
          ),
          SummaryTableRow(
            label: l10n.stocks,
            val1: _money(_typeOf(first, 'stock')),
            val2: col2('stock'),
            isOdd: true,
          ),
          SummaryTableRow(
            label: l10n.bonds,
            val1: _money(_typeOf(first, 'bond')),
            val2: col2('bond'),
            isOdd: false,
          ),
          SummaryTableRow(
            label: l10n.totalAssets,
            val1: _money(_totalOf(first)),
            val2: col2('total'),
            isOdd: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Орлого/зарлага — transactions-ийн төрөл бүрээс нэг мөр (байхгүй бол 0₮)
  Widget _buildCashFlowSection(AppLocalizations l10n, ThemeData theme) {
    final start = _formatQueryDateDot(_startDate());
    final end = _formatQueryDateDot(DateTime.now());

    return Column(
      children: [
        // SummaryTableRow(
        //   label: l10n.incomeExpense,
        //   val1: l10n.selectedPeriod,
        //   isOdd: true,
        // ),
        // SummaryTableRow(
        //   label: l10n.incomeSalary,
        //   val1: _money(_txnAmount('cash')),
        //   isOdd: false,
        // ),
        // SummaryTableRow(
        //   label: l10n.stockProfit,
        //   val1: _money(_txnAmount('stock')),
        //   isOdd: true,
        // ),
        // SummaryTableRow(
        //   label: l10n.bondPrincipal,
        //   val1: _money(_txnAmount('bond')),
        //   isOdd: true,
        // ),
        SummaryTableRow(
          label: l10n.account,
          val1: '$start - $end',
          isOdd: true,
        ),
        SummaryTableRow(
          label: l10n.exchangeRateGain,
          val1: _money(_txnAmount('rateincome')),
          isOdd: false,
        ),
        SummaryTableRow(
          label: l10n.dividendProfit,
          val1: _money(_txnAmount('dividend')),
          isOdd: true,
        ),
        SummaryTableRow(
          label: l10n.interestIncome,
          val1: _money(_txnAmount('rateincome')),
          isOdd: false,
        ),
      ],
    );
  }
}
