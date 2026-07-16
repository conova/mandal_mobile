import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/stock_row_format.dart';
import '../../models/market_instrument.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_button.dart';

/// Барьцаалах захиалга — ширхэгээ сонгоод хүлээн авах дүнгээ хараад
/// баталгаажуулалт руу шилжинэ.
class PledgeBondOrderScreen extends StatefulWidget {
  const PledgeBondOrderScreen({super.key});

  @override
  State<PledgeBondOrderScreen> createState() => _PledgeBondOrderScreenState();
}

class _PledgeBondOrderScreenState extends State<PledgeBondOrderScreen> {
  final TextEditingController _quantityController =
      TextEditingController(text: '0');
  final FocusNode _quantityFocus = FocusNode();

  MarketInstrument? _bond;
  bool _argsParsed = false;

  /// Нэгж үнэ, шимтгэл — API-д одоогоор байхгүй тул демо утгууд.
  /// CLOSEPRICE ирвэл түүгээр нэгж үнийг тооцно.
  static const double _fallbackUnitPrice = 900000;
  static const double _fee = 1000;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _bond = MarketInstrument.fromJson(Map<String, dynamic>.from(args));
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  bool get _isForeign => _bond?.isForeign ?? false;

  double get _unitPrice => _bond?.closePrice ?? _fallbackUnitPrice;

  /// Боломжит ширхэг — эзэмшлийн дүнг нэгж үнэд хуваасан
  int get _maxQuantity {
    final amt = _bond?.amt ?? 0;
    if (_unitPrice <= 0) return 0;
    return (amt / _unitPrice).floor();
  }

  int get _quantity => int.tryParse(_quantityController.text) ?? 0;

  /// Хүлээн авах дүн = ширхэг × нэгж үнэ − шимтгэл
  double get _receiveAmount {
    final total = _quantity * _unitPrice;
    return total <= 0 ? 0 : (total - _fee).clamp(0, double.infinity);
  }

  void _setQuantity(int value) {
    final clamped = value.clamp(0, _maxQuantity);
    setState(() {
      _quantityController.text = clamped.toString();
      _quantityController.selection = TextSelection.collapsed(
        offset: _quantityController.text.length,
      );
    });
  }

  void _handlePlaceOrder() {
    Navigator.pushNamed(
      context,
      '/pledge_bond_confirmation',
      arguments: {
        'bond': _bond?.raw,
        'quantity': _quantity,
        'unitPrice': _unitPrice,
        'fee': _fee,
        'receiveAmount': _receiveAmount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final name = _bond?.name ?? '';
    final subtitle = _bond?.subtitle ?? '';

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: CircleBackButton(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Нэр + дэд нэр
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  name,
                  style: theme.textTheme.headlineMedium?.copyWith(
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
                        color: extendedColors.neutral300,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.availableAmountLabel}: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral300,
                  ),
                ),
                Flexible(
                  child: Text(
                    formatStockAmount(
                      _bond?.amt,
                      isForeign: _isForeign,
                      decimals: 0,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.primaryMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Барьцаалах ширхэг
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: extendedColors.bgBase,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: extendedColors.primaryMain,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.pledgeQuantityLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          focusNode: _quantityFocus,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (v) => _setQuantity(int.tryParse(v) ?? 0),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: extendedColors.neutral100,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      _buildStepperButton(
                        Icons.remove,
                        () => _setQuantity(_quantity - 1),
                        extendedColors,
                      ),
                      const SizedBox(width: 12),
                      _buildStepperButton(
                        Icons.add,
                        () => _setQuantity(_quantity + 1),
                        extendedColors,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.availablePieces(_maxQuantity.toString()),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Өртөг + хүлээн авах дүн
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    theme,
                    extendedColors,
                    l10n.costLabel,
                    'Бондын хүү +6%',
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryRow(
                    theme,
                    extendedColors,
                    l10n.receiveAmountLabel,
                    formatStockAmount(
                      _receiveAmount,
                      isForeign: _isForeign,
                      decimals: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
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
            onPressed: _quantity > 0 ? _handlePlaceOrder : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton(
    IconData icon,
    VoidCallback onTap,
    ExtendedColors extendedColors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: extendedColors.neutral100, size: 24),
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    ExtendedColors extendedColors,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: extendedColors.neutral100,
        ),
      ],
    );
  }
}
