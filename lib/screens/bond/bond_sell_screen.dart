import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../services/auth_service.dart';
import '../../widgets/circle_back_button.dart';
import '../components/bond/bond_price_slider.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_order_board.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_button.dart';

class BondSellScreen extends StatefulWidget {
  const BondSellScreen({super.key});

  @override
  State<BondSellScreen> createState() => _BondSellScreenState();
}

class _BondSellScreenState extends State<BondSellScreen> {
  int _quantity = 1;
  Map<String, dynamic> _bond = const {};
  bool _argsParsed = false;
  double _selectedPrice = 0;

  /// Шимтгэлийн хувь (1 = 1%) — /user/fees-аас STOCKTYPE-аар нь татна
  double _feePct = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) _bond = Map<String, dynamic>.from(args);
    _selectedPrice = _unitPrice;
    _fetchFee();
  }

  Future<void> _fetchFee() async {
    final pct = await context.read<AuthService>().getFeePercent(
          stockType: _bond['STOCKTYPE']?.toString() ?? '',
        );
    if (mounted) setState(() => _feePct = pct);
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

  double get _unitPrice =>
      _num(['UNITPRICE', 'CLOSEPRICE', 'STOCKPRICE', 'PRICE']);

  double get _ownedAmount => _num(['AMT']);

  bool get _isForeign => _bond['ISFOREIGN']?.toString() == '1';

  bool get _isOpen => _bond['ISOPEN']?.toString() == '1';

  /// Эзэмшиж буй ширхэг — CNT талбар ирвэл түүнийг, үгүй бол дүн/нэгж үнэ
  int get _maxQuantity {
    final cnt = _num(['CNT', 'CURRENTBAL']);
    if (cnt > 0) return cnt.floor();
    if (_unitPrice > 0) return (_ownedAmount / _unitPrice).floor();
    return 0;
  }

  double get _price => _selectedPrice > 0 ? _selectedPrice : _unitPrice;
  double get _total => _quantity * _price;
  double get _fee => _total * _feePct / 100;

  /// Хүлээн авах дүн — нийт дүнгээс шимтгэл хассан
  double get _proceeds => _total - _fee;

  void _placeOrder() {
    final l10n = AppLocalizations.of(context)!;
    final exp = DateTime.now().add(const Duration(days: 30));
    String two(int n) => n.toString().padLeft(2, '0');
    final symbol = _str(['SYMBOL']);

    Navigator.pushNamed(
      context,
      '/bond_sell_confirmation',
      arguments: {
        'bond': _bond,
        'qty': _quantity,
        'price': _price,
        'fee': _fee,
        'feePct': _feePct,
        'total': _proceeds,
        'isForeign': _isForeign,
        'totalLabel': l10n.receivableAmountLabel,
        'order': {
          'STOCKCODE': _str(['STOCKCODE']),
          'CNT': _quantity.toString(),
          'PRICE': _price.toString(),
          // 1 — зарах
          'TXNTYPE': '1',
          'ORDERTYPE': '1',
          'CONDID': '18',
          'DESCR': 'App: $symbol бонд зарах $_quantity ширхэг, '
              'нэгж үнэ $_price',
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

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
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
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    _str(['STOCKNAME', 'COMPNAME', 'SYMBOL']),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    _str(['COMPNAME2', 'TYPENAME']),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.ownedAmountLabel}: ${formatStockAmount(_ownedAmount, isForeign: _isForeign, decimals: 0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.primaryMain,
                fontWeight: AppTextStyles.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBadge(
              _isOpen ? l10n.open : l10n.closed,
              extendedColors.primary100,
              extendedColors.primaryMain,
              theme,
            ),
            const SizedBox(height: 32),
            if (_unitPrice > 0)
              BondPriceSlider(
                // Нэгж үнийн ±2%-ийн мужид зарах үнээ сонгоно
                min: _unitPrice * 0.98,
                max: _unitPrice * 1.02,
                initialValue: _unitPrice,
                onChanged: (price) {
                  setState(() => _selectedPrice = price);
                },
              ),
            const SizedBox(height: 24),
            BondQuantitySelector(
              maxQuantity: _maxQuantity,
              initialQuantity: 1,
              onChanged: (value) {
                setState(() {
                  _quantity = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildProceedsCard(l10n, extendedColors, theme),
            const SizedBox(height: 24),
            _buildInfoBanner(l10n, extendedColors, theme),
            const SizedBox(height: 32),
            BondOrderBoard(
              orders: [
                BondOrderEntry(price: 993000, quantity: 50),
                BondOrderEntry(price: 994000, quantity: 24),
                BondOrderEntry(price: 1005000, quantity: 20),
                BondOrderEntry(price: 1010000, quantity: 10),
              ],
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: extendedColors.bgBase,
          boxShadow: [
            BoxShadow(
              color: extendedColors.neutral500,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: l10n.placeOrder,
            onPressed: _quantity > 0 && _price > 0 ? _placeOrder : null,
          ),
        ),
      ),
    );
  }

  Widget _buildProceedsCard(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              l10n.receivableAmountLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    formatStockAmount(_proceeds, isForeign: _isForeign, decimals: 0),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: extendedColors.neutral100,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: extendedColors.primary100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: extendedColors.neutral100,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.sellPriceDesc,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral100,
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
