import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';

class IncomeAccountDetailScreen extends StatefulWidget {
  const IncomeAccountDetailScreen({super.key});

  @override
  State<IncomeAccountDetailScreen> createState() =>
      _IncomeAccountDetailScreenState();
}

class _IncomeAccountDetailScreenState extends State<IncomeAccountDetailScreen> {
  bool _isSettingPrimary = false;
  bool? _isPrimaryOverride;

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
      
      // Шинэчилсэн мэдээллийг татаж кэшийг шинэчилнэ (notifyListeners дуудна)
      await auth.refreshUserInfo();
      
      if (!mounted) return;
      setState(() {
        _isSettingPrimary = false;
        _isPrimaryOverride = true;
      });
      CustomSnackbar.show(context, message: message);
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
    final extendedColors = theme.extension<ExtendedColors>()!;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final accountNumber = args['accountNumber']?.toString() ?? '';
    final bankName = args['bankName']?.toString() ?? '';
    final receiver = args['receiver']?.toString() ?? '';
    
    // Default to args, but allow override after setting primary
    final isPrimary = _isPrimaryOverride ?? (args['isPrimary'] == true);

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircleBackButton(
              onPressed: () {
                // If we changed to primary, tell the previous screen to refresh
                Navigator.pop(context, _isPrimaryOverride == true);
              },
            ),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            isPrimary ? l10n.primaryAccount : l10n.details,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildInfoCard(l10n.ibanNumber, accountNumber, theme, extendedColors),
            const SizedBox(height: 12),
            _buildInfoCard(l10n.bank, bankName, theme, extendedColors),
            const SizedBox(height: 12),
            _buildInfoCard(l10n.receiver, receiver, theme, extendedColors),
            if (isPrimary) ...[
              const SizedBox(height: 24,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  l10n.incomeAccBenefitPrompt,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
              ),
            ],
            const Spacer(),
            const SizedBox(height: 24),
            // Аль хэдийн үндсэн данс бол primary болгох товч харуулахгүй
            if (!isPrimary) ...[
              CustomButton(
                label: l10n.setAsDefaultAccount,
                onPressed:
                _isSettingPrimary ? null : () => _handleSetPrimary(args),
                isLoading: _isSettingPrimary,
                variant: CustomButtonVariant.secondary,
              ),
              const SizedBox(height: 12),
            ],
            CustomButton(
              label: l10n.deleteAccount,
              onPressed: _isSettingPrimary ? null : _handleChangeAccount,
              variant: CustomButtonVariant.error,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, ThemeData theme, dynamic extendedColors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral100,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
