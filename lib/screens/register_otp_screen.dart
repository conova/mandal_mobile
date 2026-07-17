import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import 'components/shared/auth_otp_form.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  String? _sessionId;
  late Map<String, dynamic> _args;
  late String _phone;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _phone = _args['phone'] as String;
    _sessionId = _args['sessionId'] as String?;
  }

  Future<void> _handleResend() async {
    if (_sessionId == null) return;
    try {
      final auth = context.read<AuthService>();
      final data = await auth.sendOtp('sms', sessionId: _sessionId);

      // Шинэ sessionId ирвэл шинэчилнэ
      final newSessionId = data['sessionId'] as String?;
      if (newSessionId != null && newSessionId.isNotEmpty) {
        setState(() => _sessionId = newSessionId);
      }

      final otp = data['otp']?.toString();
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: otp != null ? 'OTP код: $otp' : 'Кодыг дахин илгээлээ',
          type: CustomSnackbarType.info,
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
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
      backgroundColor: colorScheme.surface,
      appBar: const AuthStepAppBar(stepText: '1/4'),
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
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              l10n.codeSentTo(_phone),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            AuthOtpForm(
              key: ValueKey(_sessionId ?? 'no-session'),
              sessionId: _sessionId,
              onSuccess: () => Navigator.pushNamed(
                context,
                '/register_password',
                arguments: {..._args, 'sessionId': _sessionId},
              ),
              onResend: _handleResend,
            ),
          ],
        ),
      ),
    );
  }
}
