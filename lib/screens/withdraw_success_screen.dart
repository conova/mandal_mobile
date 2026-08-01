import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';

class WithdrawSuccessScreen extends StatelessWidget {
  const WithdrawSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return PopScope(
      // Зарлага амжилттай — system back-аар дууссан урсгал руу буцахын
      // оронд үндсэн дэлгэц рүү гарна
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      },
      child: Scaffold(
        backgroundColor: extendedColors.bgBase,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Success image
                Image.asset(
                  'assets/images/ready_trade.png',
                  width: 210,
                  height: 210,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.check_circle_outline,
                    size: 96,
                    color: extendedColors.primaryMain,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  l10n.withdrawSuccess,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  textAlign: TextAlign.center,
                  l10n.withdrawSuccessDesc,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: l10n.finish,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                      (route) => false,
                    ),
                    variant: CustomButtonVariant.primary,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
