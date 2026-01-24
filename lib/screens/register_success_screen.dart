import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_button.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Success icon with 3D effect
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF1E8675).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circles for depth
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E8675).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 30,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E8675).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 20,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E8675).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Main checkmark
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3E3F),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF1E8675),
                      size: 70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              l10n.registrationSuccess,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.registrationSuccessMessage,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            CustomButton(
              label: l10n.finish,
              onPressed: () {
                // Navigate to main screen
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
              },
              variant: CustomButtonVariant.primary,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
