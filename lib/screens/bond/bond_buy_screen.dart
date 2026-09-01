import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/market_instrument.dart';
import '../../services/auth_service.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/currency_suffix_formatter.dart';
import '../../widgets/custom_svg_icon.dart';
import '../../widgets/release_locked_amount_sheet.dart';
import '../components/bond/bond_payment_details_bottom_sheet.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_payment_details.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_button.dart';

class BondBuyScreen extends StatefulWidget {
  const BondBuyScreen({super.key});

  @override
  State<BondBuyScreen> createState() => _BondBuyScreenState();
}

class _BondBuyScreenState extends State<BondBuyScreen> {
  int _quantity = 0;
  double _availableCash = 0;
  double _lockedAmount = 0;
  bool _isLoading = true;

  MarketInstrument? _bond;
  bool _argsParsed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsParsed) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is MarketInstrument) {
        _bond = args;
      } else if (args is Map) {
        _bond = MarketInstrument.fromJson(Map<String, dynamic>.from(args));
      }
      _argsParsed = true;
    }
    _fetchPortfolioSummary();
  }

  Future<void> _fetchPortfolioSummary() async {
    try {
      final summary = await context.read<AuthService>().getPortfolioSummary();
      if (!mounted) return;
      setState(() {
        _availableCash = summary.cashBalance;
        _lockedAmount = summary.holdAmount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching portfolio summary: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double get _unitPrice => _bond?.stockPrice ?? _bond?.closePrice ?? 0;
  double get _totalPayment => _quantity * _unitPrice;

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
                    _bond?.name ?? '',
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
                      _bond?.subtitle ?? '',
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
                  CurrencySuffixFormatter.format(_availableCash.toString(),
                      suffix: '₮'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.primaryMain,
                    fontWeight: AppTextStyles.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            BondQuantitySelector(
              maxQuantity: 8000,
              onChanged: (quantity) {
                setState(() {
                  _quantity = quantity;
                });
              },
            ),
            const SizedBox(height: 24),
            BondPaymentDetails(
              totalPayment: CurrencySuffixFormatter.format(_totalPayment.toString(), suffix: '₮'),
              totalReturn: '0₮', // This would need calculation based on interest rate and terms
              onDetailsPressed: () {
                // Show more details
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => BondPaymentDetailsBottomSheet(
                    quantity: _quantity,
                    piecePrice: _unitPrice,
                    accruedInterest: 0, // Placeholder
                    commissionRate: 0.001, // Placeholder or fetch from bond info
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
              color: extendedColors.neutral500.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      '${l10n.lockedAmountLabel}: ${CurrencySuffixFormatter.format(_lockedAmount.toString(), suffix: '₮')}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ReleaseLockedAmountSheet.show(context),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: l10n.placeOrder,
                    onPressed: _quantity > 0
                        ? () => Navigator.pushNamed(
                              context,
                              '/bond_confirmation',
                              arguments: {
                                'bond': _bond,
                                'quantity': _quantity,
                                'price': _unitPrice,
                              },
                            )
                        : null,
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
