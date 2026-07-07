import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import 'components/shared/auth_otp_form.dart';

class ChangePasswordCodeScreen extends StatefulWidget {
  const ChangePasswordCodeScreen({super.key});

  @override
  State<ChangePasswordCodeScreen> createState() =>
      _ChangePasswordCodeScreenState();
}

class _ChangePasswordCodeScreenState extends State<ChangePasswordCodeScreen> {
  String? _sessionId;
  String? _channel;
  late String _value;
  late Map<String, dynamic> _args;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _sessionId = _args['sessionId'] as String?;
    _channel = _args['channel'] as String?;
    _value = _args['value'] as String;
  }

  Future<void> _handleResend() async {
    if (_sessionId == null) return;
    try {
      final auth = context.read<AuthService>();
      final normalized = (_channel?.toLowerCase() == 'email') ? 'email' : 'sms';
      // Нэвтэрсэн үед auth header илгээж sessionId оруулахгүй;
      // нэвтрээгүй үед sessionId-г дамжуулна.
      final data = await auth.sendOtp(
        normalized,
        sessionId: auth.isAuthenticated ? null : _sessionId,
      );

      // Хариунд шинэ sessionId ирвэл өөрсдийнхөө state-ийг шинэчилнэ
      // (verifyOtp шинэ sessionId-аар хийгдэнэ).
      final newSessionId = data['sessionId'] as String?;
      if (newSessionId != null && newSessionId.isNotEmpty) {
        setState(() => _sessionId = newSessionId);
      }

      // TEST: OTP код харуулах
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
              style: theme.textTheme.headlineSmall?.copyWith(
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
            // Key-аар AuthOtpForm-ийг шинэ sessionId-той дахин build хийлгэх
            AuthOtpForm(
              key: ValueKey(_sessionId ?? 'no-session'),
              sessionId: _sessionId,
              onSuccess: () => Navigator.pushNamed(
                context,
                '/change_password_new',
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
