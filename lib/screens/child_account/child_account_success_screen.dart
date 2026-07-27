import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/custom_button.dart';

/// Хүүхдийн данс нээх — амжилттай дууссан дэлгэц.
class ChildAccountSuccessScreen extends StatelessWidget {
  const ChildAccountSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      // Back дарахад дундын алхмууд руу буцахгүй — profile руу шууд гарна
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _finish(context);
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Image.asset(
                  'assets/images/success_check.png',
                  height: 220,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.check_circle,
                    size: 120,
                    color: extendedColors.primaryMain,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.registrationSuccess,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.childSuccessDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: extendedColors.neutral200,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: l10n.finish,
                    onPressed: () => _finish(context),
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

  /// Урсгалын бүх дэлгэцийг хааж profile руу буцна
  void _finish(BuildContext context) {
    Navigator.popUntil(
      context,
      (route) =>
          route.settings.name == '/profile' || route.isFirst,
    );
  }
}
