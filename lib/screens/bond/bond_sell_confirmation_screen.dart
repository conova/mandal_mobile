import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../components/shared/swipe_order_confirmation.dart';

/// Бонд зарах захиалгын баталгаажуулалт — дундын [SwipeOrderConfirmation]
/// component дээр суурилсан. Чирж баталгаажуулахад /order/new API-г дуудна.
///
/// Route args: { bond: raw map, order: order body, qty, price, fee, total,
///               isForeign }
class BondSellConfirmationScreen extends StatelessWidget {
  const BondSellConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final bond = args['bond'] is Map
        ? Map<String, dynamic>.from(args['bond'] as Map)
        : const <String, dynamic>{};
    final order = args['order'] is Map
        ? Map<String, dynamic>.from(args['order'] as Map)
        : const <String, dynamic>{};
    final qty = (args['qty'] as num?)?.toInt() ?? 0;
    final price = (args['price'] as num?)?.toDouble() ?? 0;
    final fee = (args['fee'] as num?)?.toDouble() ?? 0;
    final total = (args['total'] as num?)?.toDouble() ?? 0;
    final isForeign = args['isForeign'] == true;
    final feePct = (args['feePct'] as num?)?.toDouble() ?? 0;

    final name =
        (bond['STOCKNAME'] ?? bond['COMPNAME'] ?? bond['SYMBOL'])?.toString() ??
            '';
    final subtitle = (bond['COMPNAME2'] ?? bond['TYPENAME'])?.toString() ?? '';
    final isOpen = bond['ISOPEN']?.toString() == '1';

    return SwipeOrderConfirmation(
      title: name,
      subtitle: subtitle,
      details: [
        OrderDetailItem(l10n.type, isOpen ? l10n.open : l10n.closed),
        OrderDetailItem(l10n.sellQuantity, formatNumbers(qty)),
        OrderDetailItem(
          l10n.unitPrice,
          formatStockAmount(price, isForeign: isForeign, decimals: 0),
        ),
        OrderDetailItem(
          feePct > 0
              ? '${l10n.commissionLabel} ($feePct%)'
              : l10n.commissionLabel,
          formatStockAmount(fee, isForeign: isForeign, decimals: 0),
        ),
      ],
      totalLabel: l10n.receivableAmountLabel,
      totalValue: formatStockAmount(total, isForeign: isForeign, decimals: 0),
      successTitle: l10n.orderPlacedSuccess,
      successDescription: l10n.sellOrderSuccessDesc,
      successButtonLabel: l10n.viewOrders,
      // Чирж баталгаажуулахад захиалгаа server рүү илгээнэ
      onConfirm: () async {
        if (order.isEmpty) return false;
        try {
          await context.read<AuthService>().createOrders([order]);
          return true;
        } catch (e) {
          if (context.mounted) CustomSnackbar.showError(context, e);
          return false;
        }
      },
    );
  }
}
