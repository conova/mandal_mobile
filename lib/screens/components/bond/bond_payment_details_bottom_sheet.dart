import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mandal_capital/screens/components/bond/accrued_interest_desc_bottom_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_svg_icon.dart';

Future<void> showBondPaymentDetailsSheet({
  required BuildContext context,
  required int quantity,
  required double piecePrice,
  required double accruedInterest,
  required double commissionRate, // e.g., 0.001 for 0.1%
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BondPaymentDetailsBottomSheet(
      quantity: quantity,
      piecePrice: piecePrice,
      accruedInterest: accruedInterest,
      commissionRate: commissionRate,
    ),
  );
}

class BondPaymentDetailsBottomSheet extends StatelessWidget {
  final int quantity;
  final double piecePrice;
  final double accruedInterest;
  final double commissionRate;

  const BondPaymentDetailsBottomSheet({
    super.key,
    required this.quantity,
    required this.piecePrice,
    required this.accruedInterest,
    required this.commissionRate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final currencyFormat = NumberFormat('#,##0.00');

    final unitPrice = piecePrice + accruedInterest;
    final commission = quantity * unitPrice * commissionRate;
    final totalPayment = (quantity * unitPrice) + commission;

    return Container(
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: extendedColors.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.totalPriceBreakdown,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _DataCard(
                children: [
                  _DataRow(
                    label: l10n.buyQuantity,
                    value: quantity.toString(),
                  ),
                  const SizedBox(height: 16),
                  _DataRow(
                    label: l10n.unitPrice,
                    value: '${currencyFormat.format(unitPrice)}₮',
                  ),
                  const SizedBox(height: 16),
                  _DataRow(
                    label: '${l10n.commissionLabel} (${(commissionRate * 100).toStringAsFixed(1)}%)',
                    value: '${currencyFormat.format(commission)}₮',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: _DashedDivider(),
                  ),
                  _DataRow(
                    label: l10n.totalPayment,
                    value: '${currencyFormat.format(totalPayment)}₮',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.unitPriceExplanation,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.unitPriceFormula,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _DataCard(
                children: [
                  _DataRow(
                    label: l10n.piecePrice,
                    value: '${currencyFormat.format(piecePrice)}₮',
                  ),
                  const SizedBox(height: 16),
                  _DataRow(
                    label: l10n.accruedInterest,
                    value: '${currencyFormat.format(accruedInterest)}₮',
                    isInfo: true,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: _DashedDivider(),
                  ),
                  _DataRow(
                    label: l10n.unitPrice,
                    value: '${currencyFormat.format(unitPrice)}₮',
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomButton(
                  label: l10n.close,
                  onPressed: () => Navigator.pop(context),
                  variant: CustomButtonVariant.tertiary,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final List<Widget> children;

  const _DataCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isInfo;

  const _DataRow({
    required this.label,
    required this.value,
    this.isInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral200,
              fontWeight: FontWeight.w200,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isInfo) ...[
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AccruedInterestDescBottomSheet(),
                  ),
                  child: CustomSvgIcon(
                    'info-circle',
                    color: extendedColors.primaryMain,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: extendedColors.neutral400),
              ),
            );
          }),
        );
      },
    );
  }
}
