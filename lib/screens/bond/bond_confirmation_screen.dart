import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../components/shared/swipe_order_confirmation.dart';

/// Бонд авах захиалгын баталгаажуулалт — дундын [SwipeOrderConfirmation]
/// component дээр суурилсан.
class BondConfirmationScreen extends StatelessWidget {
  const BondConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Бондын мэдээлэл arguments-аар ирж болно (bond detail-аас)
    final args = ModalRoute.of(context)?.settings.arguments;
    final bond = args is Map ? Map<String, dynamic>.from(args) : null;

    final name = bond == null
        ? 'Net Capital'
        : (bond['STOCKNAME'] ?? bond['COMPNAME'] ?? bond['SYMBOL'])
                ?.toString() ??
            '';
    final subtitle = bond == null
        ? 'Нэт Капитал'
        : (bond['COMPNAME2'] ?? bond['TYPENAME'])?.toString() ?? '';
    final isOpen = bond?['ISOPEN']?.toString() == '1';

    return SwipeOrderConfirmation(
      title: name,
      subtitle: subtitle,
      details: [
        OrderDetailItem(
          l10n.type,
          bond == null ? l10n.closed : (isOpen ? l10n.open : l10n.closed),
        ),
        OrderDetailItem(l10n.buyQuantity, '42'),
        OrderDetailItem(l10n.unitPrice, '100,000₮'),
        OrderDetailItem('${l10n.commissionLabel} (0.1%)', '4,200₮'),
      ],
      totalLabel: l10n.totalPayment,
      totalValue: '42,042,000₮',
      successTitle: l10n.orderPlacedSuccess,
      successDescription: l10n.orderPlacedDesc,
      successButtonLabel: l10n.viewOrders,
    );
  }
}
