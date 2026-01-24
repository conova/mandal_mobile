import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';

class IncomeAccountDetailScreen extends StatelessWidget {
  const IncomeAccountDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              l10n.incomeAccountDetail,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.incomeAccountDetailDesc,
              style: TextStyle(
                color: theme.disabledColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(l10n.ibanNumber, 'MN650039008000110088', theme),
            const SizedBox(height: 12),
            _buildInfoCard(l10n.bank, 'Голомт банк', theme),
            const SizedBox(height: 12),
            _buildInfoCard(l10n.receiver, 'Алтанцоож Энхтүвшин', theme),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(4),
                     decoration: const BoxDecoration(
                       color: Colors.teal,
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.check, color: Colors.white, size: 16),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       l10n.accountChangedSuccess,
                       style: const TextStyle(color: Colors.white, fontSize: 14),
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: l10n.changeAccount,
              onPressed: () {
                Navigator.pushNamed(context, '/add_income_account');
              },
              variant: CustomButtonVariant.primary,
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: l10n.setAsDefaultAccount,
              onPressed: () {
                CustomSnackbar.show(context, message: 'Set as receiving account');
              },
              variant: CustomButtonVariant.secondary,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.disabledColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
