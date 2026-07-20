import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import 'components/shared/auth_otp_form.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  String? _sessionId;
  String? _channelType;
  late String _value;
  late Map<String, dynamic> _args;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _value = _args['value'] as String;
    _sessionId = _args['sessionId'] as String?;
    _channelType = _args['channelType'] as String?;
  }

  Future<void> _handleResend() async {
    if (_sessionId == null || _channelType == null) return;
    try {
      final auth = context.read<AuthService>();
      final normalized = _channelType == 'phone' ? 'sms' : _channelType!;
      final data = await auth.sendOtp(normalized, sessionId: _sessionId);

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
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: const AuthStepAppBar(stepText: '1/2'),
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
                color: extendedColors.neutral100,
              ),
            ),
            Text(
              l10n.codeSentTo(_value),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 36),
            AuthOtpForm(
              key: ValueKey(_sessionId ?? 'no-session'),
              sessionId: _sessionId,
              onSuccess: () => Navigator.pushNamed(
                context,
                '/forgot_password_new',
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
