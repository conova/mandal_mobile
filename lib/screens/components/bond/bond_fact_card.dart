import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';

/// Картын нэг үзүүлэлт — зүүнд шошго, баруунд утга
class BondFact {
  final String label;
  final String value;
  const BondFact(this.label, this.value);
}

/// Бондын үндсэн үзүүлэлтүүдийн хүрээтэй карт — доор нь "Бондын
/// танилцуулга үзэх" товчтой. Анхдагч болон хоёрдогч дизайн хуваалцана.
class BondFactCard extends StatelessWidget {
  final List<BondFact> facts;
  final VoidCallback? onPresentation;

  const BondFactCard({
    super.key,
    required this.facts,
    this.onPresentation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: extendedColors.neutral500),
      ),
      child: Column(
        children: [
          for (var i = 0; i < facts.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _FactRow(fact: facts[i]),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              size: CustomButtonSize.small,
              onPressed: onPresentation ?? () {},
              label: l10n.viewBondPresentation,
              variant: CustomButtonVariant.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final BondFact fact;

  const _FactRow({required this.fact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            fact.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTextStyles.light,
              color: extendedColors.neutral200,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Text(
            fact.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral100,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
