import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../components/shared/swipe_order_confirmation.dart';

/// Бонд барьцаалах баталгаажуулалт — дундын [SwipeOrderConfirmation]
/// component дээр суурилсан: дээш сөхөж баталгаажуулаад "ХҮСЭЛТ ИЛГЭЭЛЭЭ"
/// амжилтын дэлгэц гарна.
class PledgeBondConfirmationScreen extends StatelessWidget {
  const PledgeBondConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final bond = args['bond'] is Map
        ? Map<String, dynamic>.from(args['bond'] as Map)
        : null;
    final quantity = (args['quantity'] as num?)?.toInt() ?? 0;
    final unitPrice = (args['unitPrice'] as num?)?.toDouble() ?? 0;
    final fee = (args['fee'] as num?)?.toDouble() ?? 0;
    final receiveAmount = (args['receiveAmount'] as num?)?.toDouble() ?? 0;

    final isForeign = bond?['ISFOREIGN']?.toString() == '1';
    final name = bond == null
        ? ''
        : (bond['STOCKNAME'] ?? bond['COMPNAME'] ?? bond['SYMBOL'])
                ?.toString() ??
            '';
    final subtitle = (bond?['COMPNAME2'] ?? bond?['TYPENAME'])?.toString() ?? '';

    final phone = context.read<AuthService>().userInfo?['phone']?.toString() ??
        '';

    return SwipeOrderConfirmation(
      title: name,
      subtitle: subtitle,
      details: [
        OrderDetailItem(l10n.type, l10n.pledgeBond),
        OrderDetailItem(l10n.quantityLabel, quantity.toString()),
        OrderDetailItem(
          l10n.unitPrice,
          formatStockAmount(unitPrice, isForeign: isForeign, decimals: 0),
        ),
        OrderDetailItem(
          l10n.commissionLabel,
          formatStockAmount(fee, isForeign: isForeign, decimals: 0),
        ),
        OrderDetailItem(l10n.costLabel, 'Бондын хүү +6%'),
      ],
      totalLabel: l10n.receiveAmountLabel,
      totalValue: formatStockAmount(
        receiveAmount,
        isForeign: isForeign,
        decimals: 0,
      ),
      successTitle: l10n.requestSent,
      successDescription: l10n.requestSentDesc(phone),
      successButtonLabel: l10n.finish,
    );
  }
}
