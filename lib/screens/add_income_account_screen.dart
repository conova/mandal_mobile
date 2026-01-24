import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_input.dart';

class AddIncomeAccountScreen extends StatefulWidget {
  const AddIncomeAccountScreen({super.key});

  @override
  State<AddIncomeAccountScreen> createState() => _AddIncomeAccountScreenState();
}

class _AddIncomeAccountScreenState extends State<AddIncomeAccountScreen> {
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildBackButton(context, colorScheme),
              const SizedBox(height: 32),
              Text(
                l10n.addIncomeAccPrompt,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.incomeAccBenefitPrompt,
                style: TextStyle(color: theme.disabledColor, fontSize: 14),
              ),
              const SizedBox(height: 40),
              CustomInput(
                label: l10n.iban,
                controller: _ibanController,
                suffix: Icon(Icons.copy, color: theme.disabledColor, size: 20),
              ),
              const SizedBox(height: 20),
              CustomInput(
                label: l10n.bank,
                controller: _bankController,
              ),
              const SizedBox(height: 20),
              CustomInput(
                label: l10n.receiver,
                controller: _receiverController,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.receiverHint,
                style: TextStyle(color: theme.disabledColor, fontSize: 12),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    CustomSnackbar.show(
                      context, 
                      message: l10n.orderUpdated, // Or a specific success message
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceVariant,
                    foregroundColor: colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }


}
