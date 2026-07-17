import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/circle_back_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';

enum CurrencyType { mnt, usd }

class CurrencyDetailScreen extends StatelessWidget {
  const CurrencyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    final currencyType = args == 'usd' ? CurrencyType.usd : CurrencyType.mnt;

    final isMnt = currencyType == CurrencyType.mnt;
    final accentColor = isMnt ? extendedColors.primaryMain : extendedColors.neutral100;
    final currencySymbol = isMnt ? '₮' : '\$';
    final title = isMnt ? l10n.tugrik : l10n.dollar;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            _buildHeader(
              context: context,
              theme: theme,
              extendedColors: extendedColors,
              accentColor: accentColor,
              title: title,
              amount: isMnt ? '0.00₮' : '0.00\$',
              currencySymbol: currencySymbol,
              isMnt: isMnt,
            ),
            const SizedBox(height: 24),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: l10n.income,
                      size: CustomButtonSize.small,
                      icon: const Icon(Icons.add),
                      variant: isMnt ? CustomButtonVariant.primary : CustomButtonVariant.neutral,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/income_method'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      label: l10n.expense,
                      size: CustomButtonSize.small,
                      icon: const Icon(Icons.sync),
                      variant: CustomButtonVariant.tertiary,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/withdraw_method'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 16),
            // General Info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.generalInfo,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context: context,
              theme: theme,
              extendedColors: extendedColors,
              icon: 'coins-hand',
              label: l10n.cash,
              amount: isMnt ? '0.00₮' : '0.00\$',
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context: context,
              theme: theme,
              extendedColors: extendedColors,
              icon: 'file-check-02',
              label: l10n.lockedAmountLabel,
              amount: isMnt ? '0.00₮' : '0.00\$',
              trailing: CustomButton(
                label: l10n.release,
                size: CustomButtonSize.small,
                minWidth: 78,
                variant: CustomButtonVariant.tertiary,
                onPressed: () =>
                    Navigator.pushNamed(context, '/release_locked'),
              ),
            ),
            const SizedBox(height: 24),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 24),
            // History section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.history,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            ..._buildTransactionHistory(
              theme: theme,
              extendedColors: extendedColors,
              currencyType: currencyType,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required Color accentColor,
    required String title,
    required String amount,
    required String currencySymbol,
    required bool isMnt,
  }) {
    final gradientColors = isMnt
        ? [extendedColors.primary200, extendedColors.bgBase]
        : [extendedColors.bgTertiary, extendedColors.bgBase];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              // Back товч зүүн талд, валютын icon мөрийн голд
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CircleBackButton(),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: CustomSvgIcon(
                              isMnt ? 'tugrug-01': 'currency-dollar',
                              size: 22,
                              color: extendedColors.bgBase,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: FontWeight.w200
              ),
            ),
            const SizedBox(height: 8),
            _buildAmountText(amount, theme, extendedColors),
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountText(String amount, ThemeData theme, ExtendedColors extendedColors) {
    // Split amount into integer and decimal parts
    final dotIndex = amount.indexOf('.');
    if (dotIndex == -1) {
      return Text(
        amount,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: extendedColors.neutral100,
        ),
      );
    }

    final integerPart = amount.substring(0, dotIndex);
    final decimalPart = amount.substring(dotIndex);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: integerPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          TextSpan(
            text: decimalPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required String icon,
    required String label,
    required String amount,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: CustomSvgIcon(icon, color: extendedColors.neutral100, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CustomSvgIcon('info-circle', size: 20, color: extendedColors.neutral300,)
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  List<Widget> _buildTransactionHistory({
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required CurrencyType currencyType,
    required String currencySymbol,
  }) {
    final isMnt = currencyType == CurrencyType.mnt;
    final currencyLabel = isMnt ? 'MNT' : 'USD';

    final transactions = isMnt
        ? [
            _TransactionData(
              type: 'Зарлага',
              currency: currencyLabel,
              date: '2025.08.20 18:23',
              amount: '-410,000.00₮',
              isIncome: false,
            ),
            _TransactionData(
              type: 'Зарлага',
              currency: currencyLabel,
              date: '2025.08.20 18:23',
              amount: '-10,000,000.00₮',
              isIncome: false,
            ),
            _TransactionData(
              type: 'Орлого',
              currency: currencyLabel,
              date: '2025.08.20 18:23',
              amount: '50,000,000.00₮',
              isIncome: true,
            ),
          ]
        : [
            _TransactionData(
              type: 'Зарлага',
              currency: currencyLabel,
              date: '2025.08.20 18:23',
              amount: '-100.00\$',
              isIncome: false,
            ),
            _TransactionData(
              type: 'Орлого',
              currency: currencyLabel,
              date: '2025.08.20 18:23',
              amount: '250.00\$',
              isIncome: true,
            ),
          ];

    return transactions.map((tx) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tx.isIncome
                    ? extendedColors.primary100
                    : extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CustomSvgIcon(
                  isMnt ? 'tugrug-01': 'currency-dollar',
                  color: tx.isIncome ? extendedColors.primaryMain: extendedColors.neutral200,)
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tx.type} - ${tx.currency}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.date,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              tx.amount,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w300,
                color: tx.isIncome
                    ? extendedColors.primaryMain
                    : extendedColors.neutral100,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _TransactionData {
  final String type;
  final String currency;
  final String date;
  final String amount;
  final bool isIncome;

  const _TransactionData({
    required this.type,
    required this.currency,
    required this.date,
    required this.amount,
    required this.isIncome,
  });
}
