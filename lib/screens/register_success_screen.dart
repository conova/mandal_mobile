import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../theme/extended_colors.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      // Бүртгэл дууссан — system back-аар дууссан бүртгэлийн урсгал руу
      // буцахын оронд үндсэн дэлгэц рүү гарна
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      },
      child: Scaffold(
        backgroundColor: extendedColors.bgBase,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/success.png',
                    width: 215,
                    height: 215,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    l10n.registrationSuccess,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.registrationSuccessMessage,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48,),
                  CustomButton(
                    label: l10n.finish,
                    onPressed: () {
                      // Navigate to main screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main',
                            (route) => false,
                      );
                    },
                    variant: CustomButtonVariant.primary,
                  ),
                  const SizedBox(height: 32),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
