import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';

class IncomeAccountDetailScreen extends StatefulWidget {
  const IncomeAccountDetailScreen({super.key});

  @override
  State<IncomeAccountDetailScreen> createState() =>
      _IncomeAccountDetailScreenState();
}

class _IncomeAccountDetailScreenState extends State<IncomeAccountDetailScreen> {
  bool _isSettingPrimary = false;

  /// Данс солих буюу шинэ данс нэмэх дэлгэц рүү шилжинэ.
  Future<void> _handleChangeAccount() async {
    final added = await Navigator.pushNamed(context, '/add_income_account');
    // Данс нэмэгдсэн бол жагсаалт руу буцааж шинэчлүүлнэ
    if (added == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  /// Сонгосон дансыг үндсэн (орлого авах) данс болгоно —
  /// add_account API руу isPrimary: "1" илгээнэ.
  Future<void> _handleSetPrimary(Map<String, dynamic> args) async {
    if (_isSettingPrimary) return;

    setState(() => _isSettingPrimary = true);
    try {
      final auth = context.read<AuthService>();
      final message = await auth.addAccount(
        bankCode: args['bankCode']?.toString() ?? '',
        iban: args['accountNumber']?.toString() ?? '',
        accountName: args['receiver']?.toString() ?? '',
        isPrimary: true,
      );
      if (!mounted) return;
      setState(() => _isSettingPrimary = false);
      CustomSnackbar.show(context, message: message);
      // true буцааж дансны жагсаалтыг шинэчлүүлнэ
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSettingPrimary = false);
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final accountNumber = args['accountNumber']?.toString() ?? '';
    final bankName = args['bankName']?.toString() ?? '';
    final receiver = args['receiver']?.toString() ?? '';
    final isPrimary = args['isPrimary'] == true;

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
              style: TextStyle(color: theme.disabledColor, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(l10n.ibanNumber, accountNumber, theme),
            const SizedBox(height: 12),
            _buildInfoCard(l10n.bank, bankName, theme),
            const SizedBox(height: 12),
            _buildInfoCard(l10n.receiver, receiver, theme),
            const Spacer(),
            const SizedBox(height: 24),
            CustomButton(
              label: l10n.changeAccount,
              onPressed: _isSettingPrimary ? null : _handleChangeAccount,
              variant: CustomButtonVariant.primary,
            ),
            // Аль хэдийн үндсэн данс бол primary болгох товч харуулахгүй
            if (!isPrimary) ...[
              const SizedBox(height: 12),
              CustomButton(
                label: l10n.setAsDefaultAccount,
                onPressed:
                    _isSettingPrimary ? null : () => _handleSetPrimary(args),
                isLoading: _isSettingPrimary,
                variant: CustomButtonVariant.secondary,
              ),
            ],
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
            style: TextStyle(color: theme.disabledColor, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
