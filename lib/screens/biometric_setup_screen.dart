import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class BiometricSetupScreen extends StatelessWidget {
  const BiometricSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final authService = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: FutureBuilder<List<BiometricType>>(
          future: authService.getAvailableBiometrics(),
          builder: (context, snapshot) {
            String assetPath = 'assets/images/face_id.svg';
            String title = l10n.biometricEnableTitle;

            if (snapshot.hasData) {
              final biometrics = snapshot.data!;
              if (biometrics.contains(BiometricType.face)) {
                assetPath = 'assets/images/face_id.svg';
                title = l10n.faceIdEnableTitle;
              } else if (biometrics.contains(BiometricType.fingerprint) ||
                  biometrics.contains(BiometricType.strong) ||
                  biometrics.contains(BiometricType.weak)) {
                assetPath = 'assets/images/fingerprint.svg';
                title = l10n.fingerprintEnableTitle;
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  // Biometric SVG Asset
                  SvgPicture.asset(
                    assetPath,
                    width: 120,
                    height: 120,
                    colorFilter: ColorFilter.mode(
                      extendedColors.primaryMain,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.h2.copyWith(
                      color: extendedColors.neutral100,
                      fontWeight: AppTextStyles.semiBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    l10n.biometricEnableDesc,
                    style: AppTextStyles.body2.copyWith(
                      color: extendedColors.neutral100,
                      fontWeight: AppTextStyles.extraLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),
                  // Buttons
                  CustomButton(
                    label: l10n.yesEnable,
                    onPressed: () async {
                      final authenticated = await authService
                          .authenticateWithBiometrics();
                      if (authenticated) {
                        await authService.setBiometricEnabled(true);
                        if (authService.accessToken != null) {
                          await authService.saveBiometricToken(
                            authService.accessToken!,
                          );
                        }
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/main');
                        }
                      }
                    },
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: l10n.skip,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/main');
                    },
                    variant: CustomButtonVariant.secondary,
                    fullWidth: true,
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
