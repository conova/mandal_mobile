import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import 'bond_detail_info_list.dart';

/// Хоёрдогч + ХААЛТТАЙ бондын дизайн: зөвхөн үзүүлэлтүүдийн карт +
/// танилцуулга үзэх товч.
class BondDetailClosedView extends StatelessWidget {
  final Map<String, dynamic>? bond;

  const BondDetailClosedView({super.key, required this.bond});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BondDetailInfoList(bond: bond),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            onPressed: () {},
            label: l10n.viewBondPresentation,
            variant: CustomButtonVariant.tertiary,
          ),
        ),
      ],
    );
  }
}
