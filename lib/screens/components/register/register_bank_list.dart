import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../../../../theme/extended_colors.dart';

class RegisterBankList extends StatelessWidget {
  final List<Map<String, dynamic>> banks;
  final String? selectedBank;
  final ValueChanged<String> onSelect;

  const RegisterBankList({
    super.key,
    required this.banks,
    required this.selectedBank,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: banks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final bank = banks[index];
        final isSelected = selectedBank == bank['name'];

        return InkWell(
          onTap: () => onSelect(bank['name']),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bank['color'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      bank['icon'],
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    bank['name'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                CustomSvgIcon(
                  'chevron-right',
                  size: 24,
                  color: extendedColors.neutral200,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
