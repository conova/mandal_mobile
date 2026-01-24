import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'custom_button.dart';

class SavingsCard extends StatelessWidget {
  final String title;
  final String amount;
  final String tenure;
  final String rate;
  final String endDate;
  final VoidCallback? onAddPressed;

  const SavingsCard({
    super.key,
    required this.title,
    required this.amount,
    required this.tenure,
    required this.rate,
    required this.endDate,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
              ),
              CustomButton(
                label: l10n.add,
                variant: CustomButtonVariant.secondary,
                size: CustomButtonSize.small,
                onPressed: onAddPressed,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(theme, l10n.tenureLabel, tenure),
              _buildMetric(theme, l10n.interestRate, rate),
              _buildMetric(theme, l10n.endDateLabel, endDate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
