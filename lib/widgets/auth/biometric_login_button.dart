import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
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
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;

    return FutureBuilder<List<BiometricType>>(
      future: authService.getAvailableBiometrics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final biometrics = snapshot.data!;
        IconData iconData = Icons.fingerprint;

        if (biometrics.contains(BiometricType.face)) {
          iconData = Icons.face_retouching_natural;
        } else if (biometrics.contains(BiometricType.fingerprint) ||
            biometrics.contains(BiometricType.strong) ||
            biometrics.contains(BiometricType.weak)) {
          iconData = Icons.fingerprint;
        }

        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: extendedColors.primary100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(
              iconData,
              color: extendedColors.primaryMain,
              size: 32,
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
