import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';

/// OTP амжилттай нэвтэрсний дараа харагдах биометрик идэвхжүүлэх дэлгэц.
/// Төхөөрөмжийн боломжоос хамаарч Царай (Face ID) эсвэл Хурууны хээ
/// (Fingerprint)-ийн дэлгэцийг харуулна.
///
/// "Тэгье" → биометрик баталгаажуулаад идэвхжүүлж [/main] руу шилжинэ.
/// "Алгасах" → идэвхжүүлэлгүйгээр шууд [/main] руу шилжинэ.
class BiometricEnrollmentScreen extends StatefulWidget {
  const BiometricEnrollmentScreen({super.key});

  @override
  State<BiometricEnrollmentScreen> createState() =>
      _BiometricEnrollmentScreenState();
}

class _BiometricEnrollmentScreenState extends State<BiometricEnrollmentScreen> {
  List<BiometricType> _available = [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final auth = context.read<AuthService>();
    final types = await auth.getAvailableBiometrics();
    if (!mounted) return;
    // Боломжтой биометрик байхгүй бол энэ дэлгэцийг харуулах шаардлагагүй —
    // шууд home руу шилжинэ.
    if (types.isEmpty) {
      _goHome();
      return;
    }
    setState(() {
      _available = types;
      _loading = false;
    });
  }

  bool get _isFace => _available.contains(BiometricType.face);

  Future<void> _enable() async {
    if (_busy) return;
    setState(() => _busy = true);
    final auth = context.read<AuthService>();
    try {
      final ok = await auth.authenticateWithBiometrics();
      if (!mounted) return;
      if (ok) {
        await auth.setBiometricEnabled(true);
        _goHome();
      } else {
        setState(() => _busy = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        CustomSnackbar.show(
          context,
          message: AppLocalizations.of(context)!.connectionError,
          type: CustomSnackbarType.error,
        );
      }
    }
  }

  void _goHome() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    if (_loading) {
      return Scaffold(
        backgroundColor: extendedColors.bgBase,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Icon(
                _isFace ? Icons.face_retouching_natural : Icons.fingerprint,
                size: 96,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                _isFace
                    ? l10n.biometricFaceTitle
                    : l10n.biometricFingerprintTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: extendedColors.neutral100,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.biometricEnrollDesc,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral200,
                  fontWeight: AppTextStyles.regular,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.biometricEnrollConfirm,
                  isLoading: _busy,
                  onPressed: _enable,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.skip,
                  variant: CustomButtonVariant.secondary,
                  onPressed: _busy ? null : _goHome,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
