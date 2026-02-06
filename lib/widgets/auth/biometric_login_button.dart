import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart';
import '../../theme/extended_colors.dart';

class BiometricLoginButton extends StatelessWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback? onError;

  const BiometricLoginButton({
    super.key,
    required this.onAuthenticated,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return FutureBuilder<List<BiometricType>>(
      future: authService.getAvailableBiometrics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final biometrics = snapshot.data!;
        String assetPath = 'assets/images/fingerprint.svg';

        if (biometrics.contains(BiometricType.face)) {
          assetPath = 'assets/images/face_id.svg';
        } else if (biometrics.contains(BiometricType.fingerprint) ||
            biometrics.contains(BiometricType.strong) ||
            biometrics.contains(BiometricType.weak)) {
          assetPath = 'assets/images/fingerprint.svg';
        }

        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: extendedColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              assetPath,
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                extendedColors.primaryMain,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () async {
              final authenticated = await authService
                  .authenticateWithBiometrics();
              if (authenticated) {
                onAuthenticated();
              } else {
                onError?.call();
              }
            },
          ),
        );
      },
    );
  }
}
