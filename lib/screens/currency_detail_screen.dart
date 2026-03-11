import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';

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
              amount: isMnt ? '128,000.53₮' : '128.40\$',
              currencySymbol: currencySymbol,
              isMnt: isMnt,
            ),
            const SizedBox(height: 24),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/income_method'),
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(
                        l10n.income,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: extendedColors.bgBase,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: extendedColors.bgBase,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/withdraw_method'),
                      icon: Icon(Icons.sync, size: 20, color: extendedColors.neutral100),
                      label: Text(
                        l10n.expense,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: extendedColors.neutral100,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: extendedColors.bgSecondary,
                        foregroundColor: extendedColors.neutral100,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 24),
            // General Info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.generalInfo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context: context,
              theme: theme,
              extendedColors: extendedColors,
              icon: Icons.people_outline,
              label: l10n.cash,
              amount: isMnt ? '28,000.53₮' : '100.00\$',
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context: context,
              theme: theme,
              extendedColors: extendedColors,
              icon: Icons.description_outlined,
              label: l10n.lockedAmountLabel,
              amount: isMnt ? '100,000.00₮' : '28.40\$',
              trailing: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/release_locked'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: extendedColors.neutral400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  l10n.release,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: extendedColors.neutral100,
                  ),
                ),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
        ? [extendedColors.primary200, extendedColors.primary100.withValues(alpha: 0.3)]
        : [extendedColors.bgSecondary, extendedColors.bgBase];

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
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: extendedColors.bgBase.withValues(alpha: 0.5),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: extendedColors.neutral100,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  currencySymbol,
                  style: TextStyle(
                    color: extendedColors.bgBase,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral300,
              ),
            ),
            const SizedBox(height: 8),
            _buildAmountText(amount, theme, extendedColors),
            const SizedBox(height: 24),
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
    required IconData icon,
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
            child: Icon(icon, color: extendedColors.neutral200, size: 24),
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.info_outline, size: 16, color: extendedColors.neutral400),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tx.isIncome
                    ? extendedColors.primary100.withValues(alpha: 0.3)
                    : extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  currencySymbol,
                  style: TextStyle(
                    color: tx.isIncome
                        ? extendedColors.primaryMain
                        : extendedColors.neutral300,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      fontWeight: FontWeight.w500,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              tx.amount,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
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
