import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/percent_suffix_formatter.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../services/auth_service.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_svg_icon.dart';
import '../../widgets/release_locked_amount_sheet.dart';
import '../components/bond/bond_payment_details_bottom_sheet.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_payment_details.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_button.dart';

/// Бонд авах — route args: бондын мөр (raw map, bond_detail-аас `_bond.raw`)
class BondBuyScreen extends StatefulWidget {
  const BondBuyScreen({super.key});

  @override
  State<BondBuyScreen> createState() => _BondBuyScreenState();
}

class _BondBuyScreenState extends State<BondBuyScreen> {
  int _quantity = 0;
  Map<String, dynamic> _bond = const {};
  bool _argsParsed = false;

  /// Бэлэн мөнгө, түгжигдсэн дүн — portfolio summary
  double _availableCash = 0;
  double _lockedAmount = 0;

  /// Шимтгэлийн хувь (1 = 1%) — /user/fees-аас STOCKTYPE-аар нь татна
  double _feePct = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) _bond = Map<String, dynamic>.from(args);
    _fetchSummary();
    _fetchFee();
  }

  Future<void> _fetchFee() async {
    // Анхдагч арилжаа (Primary) бол FEEIPO, бусад нь FEE
    final isPrimary =
        _bond['MARKET']?.toString().toLowerCase() == 'primary';
    final pct = await context.read<AuthService>().getFeePercent(
          stockType: _bond['STOCKTYPE']?.toString() ?? '',
          ipo: isPrimary,
        );
    if (mounted) setState(() => _feePct = pct);
  }

  Future<void> _fetchSummary() async {
    try {
      final summary = await context.read<AuthService>().getPortfolioSummary();
      if (!mounted) return;
      setState(() {
        _availableCash = summary.cashBalance - summary.holdAmount;
        _lockedAmount = summary.holdAmount;
      });
    } catch (_) {
      // Дүнгүй үлдээнэ — захиалгад саад болохгүй
    }
  }

  double _num(List<String> keys) {
    for (final k in keys) {
      final v = num.tryParse(_bond[k]?.toString() ?? '');
      if (v != null && v > 0) return v.toDouble();
    }
    return 0;
  }

  String _str(List<String> keys) {
    for (final k in keys) {
      final v = _bond[k]?.toString() ?? '';
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  /// Нэгж үнэ — бондын мөрийн боломжит талбаруудаас
  double get _unitPrice =>
      _num(['UNITPRICE', 'CLOSEPRICE', 'STOCKPRICE', 'PRICE']);

  double get _intRate => _num(['INTRATE']);

  bool get _isForeign => _bond['ISFOREIGN']?.toString() == '1';

  int get _maxQuantity =>
      _unitPrice > 0 ? (_availableCash / _unitPrice).floor() : 0;

  double get _total => _quantity * _unitPrice;
  double get _fee => _total * _feePct / 100;
  double get _totalPayment => _total + _fee;

  /// Жилийн хүүгээр тооцсон хүлээгдэж буй өгөөж
  double get _expectedReturn => _total * _intRate / 100;

  void _placeOrder() {
    final l10n = AppLocalizations.of(context)!;
    final exp = DateTime.now().add(const Duration(days: 30));
    String two(int n) => n.toString().padLeft(2, '0');
    final symbol = _str(['SYMBOL']);

    Navigator.pushNamed(
      context,
      '/bond_confirmation',
      arguments: {
        'bond': _bond,
        'qty': _quantity,
        'price': _unitPrice,
        'fee': _fee,
        'feePct': _feePct,
        'total': _totalPayment,
        'isForeign': _isForeign,
        'totalLabel': l10n.totalPayment,
        'order': {
          'STOCKCODE': _str(['STOCKCODE']),
          'CNT': _quantity.toString(),
          'PRICE': _unitPrice.toString(),
          // 0 — авах
          'TXNTYPE': '0',
          'ORDERTYPE': '1',
          'CONDID': '18',
          'DESCR': 'App: $symbol бонд авах $_quantity ширхэг, '
              'нэгж үнэ $_unitPrice',
          'EXPDATE': '${exp.year}/${two(exp.month)}/${two(exp.day)}',
          'FEE': '1',
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final name = _str(['STOCKNAME', 'COMPNAME', 'SYMBOL']);
    final subtitle = _str(['COMPNAME2', 'TYPENAME']);

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    name.isNotEmpty ? name : '-',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
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
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.availableCash}: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: AppTextStyles.bold,
                  ),
                ),
                Text(
                  formatStockAmount(_availableCash, decimals: 0),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.primaryMain,
                    fontWeight: AppTextStyles.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            BondQuantitySelector(
              maxQuantity: _maxQuantity,
              onChanged: (quantity) {
                setState(() {
                  _quantity = quantity;
                });
              },
            ),
            const SizedBox(height: 24),
            BondPaymentDetails(
              totalPayment: formatStockAmount(
                _totalPayment,
                isForeign: _isForeign,
                decimals: 0,
              ),
              yieldPercent: PercentSuffixFormatter.format(_intRate),
              // formatStockAmount(
              //   _expectedReturn,
              //   isForeign: _isForeign,
              //   decimals: 0,
              // ),
              onDetailsPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => BondPaymentDetailsBottomSheet(
                    quantity: _quantity,
                    piecePrice: _unitPrice,
                    accruedInterest: 0,
                    commissionRate: _feePct / 100,
                  ),
                );
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: extendedColors.bgBase,
          boxShadow: [
            BoxShadow(
              color: extendedColors.neutral500.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_lockedAmount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: extendedColors.primary200),
                child: Row(
                  children: [
                    CustomSvgIcon('info-circle',
                        color: extendedColors.primaryMain, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n.lockedAmountLabel}: '
                        '${formatStockAmount(_lockedAmount, decimals: 0)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ReleaseLockedAmountSheet.show(context);
                        // Цуцлалт хийсэн байж болзошгүй — дүнгээ шинэчилнэ
                        _fetchSummary();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.release,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: extendedColors.primaryMain,
                            ),
                          ),
                          CustomSvgIcon(
                            'chevron-up',
                            color: extendedColors.primaryMain,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: l10n.placeOrder,
                    onPressed:
                        _quantity > 0 && _unitPrice > 0 ? _placeOrder : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
