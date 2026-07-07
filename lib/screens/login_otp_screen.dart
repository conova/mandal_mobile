import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../services/auth_service.dart';
import 'components/shared/auth_otp_form.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  String? _sessionId;
  String? _channel;
  late String _value;
  Map<String, dynamic>? _args;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _value = _args?['value'] as String? ?? '';
    _sessionId = _args?['sessionId'] as String?;
    _channel = _args?['channel'] as String?;
  }

  /// OTP амжилттай болсны дараа: төхөөрөмж дээр биометрик боломжтой бөгөөд
  /// хараахан идэвхжээгүй бол идэвхжүүлэх дэлгэц рүү, эс бөгөөс шууд home руу.
  Future<void> _handleOtpSuccess() async {
    final auth = context.read<AuthService>();
    final available = await auth.getAvailableBiometrics();
    if (!mounted) return;
    if (available.isNotEmpty && !auth.isBiometricEnabled) {
      Navigator.pushReplacementNamed(context, '/biometric_enrollment');
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  Future<void> _handleResend() async {
    if (_sessionId == null) return;
    try {
      final channelType =
          (_channel?.toLowerCase() == 'email') ? 'email' : 'sms';
      final data = await context.read<AuthService>().sendOtp(
            channelType,
            sessionId: _sessionId,
          );

      // Шинэ sessionId ирвэл шинэчилнэ
      final newSessionId = data['sessionId'] as String?;
      if (newSessionId != null && newSessionId.isNotEmpty) {
        setState(() => _sessionId = newSessionId);
      }

      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: 'OTP код дахин илгээлээ',
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: 'OTP илгээхэд алдаа: ${e.toString().replaceFirst("Exception: ", "")}',
          type: CustomSnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const AuthStepAppBar(stepText: '2/2'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.enterCodeTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            Text(
              l10n.codeSentTo(_value),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            AuthOtpForm(
              key: ValueKey(_sessionId ?? 'no-session'),
              sessionId: _sessionId,
              onSuccess: _handleOtpSuccess,
              onResend: _handleResend,
            ),
          ],
        ),
      ),
    );
  }
}
