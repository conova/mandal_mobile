import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import 'auth_channel_selector.dart';

class AuthChannelSelectionForm extends StatefulWidget {
  final String nextRoute;
  final Map<String, dynamic>? extraArgs;

  const AuthChannelSelectionForm({
    super.key,
    required this.nextRoute,
    this.extraArgs,
  });

  @override
  State<AuthChannelSelectionForm> createState() =>
      _AuthChannelSelectionFormState();
}

class _AuthChannelSelectionFormState extends State<AuthChannelSelectionForm> {
  List<Map<String, dynamic>>? _channels;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  Future<void> _fetchChannels() async {
    final sessionId = widget.extraArgs?['sessionId'] as String?;
    final authService = context.read<AuthService>();

    // 1) sessionId бий → forgot password / register flow (нэвтрээгүй)
    if (sessionId != null) {
      try {
        final channels = await authService.getVerificationChannels(sessionId);
        if (mounted) {
          setState(() {
            _channels = channels;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = e.toString().replaceFirst('Exception: ', '');
          });
        }
      }
      return;
    }

    // 2) Нэвтэрсэн (нууц үг солих, төхөөрөмж бүртгэх г.м.) — userInfo-аас авна
    if (authService.isAuthenticated) {
      final info = authService.userInfo ?? await authService.refreshUserInfo();
      final List<Map<String, dynamic>> channels = [];
      final phone = info?['phone']?.toString();
      final email = info?['email']?.toString();
      if (phone != null && phone.isNotEmpty) {
        channels.add({'type': 'sms', 'value': phone});
      }
      if (email != null && email.isNotEmpty) {
        channels.add({'type': 'email', 'value': email});
      }
      if (mounted) {
        setState(() {
          _channels = channels;
          _isLoading = false;
          if (channels.isEmpty) {
            _error = 'Бүртгэлтэй утас эсвэл и-мэйл олдсонгүй';
          }
        });
      }
      return;
    }

    // 3) sessionId-гүй, бас нэвтрээгүй — алдаа
    setState(() {
      _isLoading = false;
      _error = 'Session ID байхгүй бөгөөд нэвтрээгүй байна';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            l10n.selectVerifyChannel,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.verifyChannelPrompt,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 48),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_isSending)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            )
          else if (_channels != null)
            ..._channels!.map((channel) {
              final type = channel['type'] as String? ?? '';
              final value = channel['value'] as String? ?? '';
              final isPhone = type == 'sms' || type == 'phone';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AuthChannelSelector(
                  icon: isPhone
                      ? Icons.smartphone_outlined
                      : Icons.email_outlined,
                  title: isPhone ? l10n.sms : l10n.emailLabel,
                  value: _maskValue(type, value),
                  onTap: () => _onChannelTap(type, value),
                ),
              );
            }),
        ],
      ),
    );
  }

  bool _isSending = false;

  /// Утга маскалах: 99054583 → 99****83
  String _maskValue(String type, String value) {
    if (value.length <= 4) return value;
    if (type == 'sms' || type == 'phone') {
      return '${value.substring(0, 2)}****${value.substring(value.length - 2)}';
    }
    // email: t.baterdene@techfi.mn → t.********@techfi.mn
    final atIndex = value.indexOf('@');
    if (atIndex > 2) {
      return '${value.substring(0, 2)}${'*' * (atIndex - 2)}${value.substring(atIndex)}';
    }
    return value;
  }

  /// send_otp руу илгээх channel нэрийг normalize хийх
  /// API "phone" буцаадаг ч send_otp "sms" хүлээн авдаг байж болно
  String _normalizeChannelType(String type) {
    if (type == 'phone') return 'sms';
    return type;
  }

  void _onChannelTap(String type, String value) async {
    if (_isSending) return;

    final authService = context.read<AuthService>();
    final sessionId = widget.extraArgs?['sessionId'] as String?;
    final isPhone = type == 'sms' || type == 'phone';
    final channelLabel = isPhone ? 'SMS' : 'Email';
    final maskedValue = _maskValue(type, value);
    final normalizedChannel = _normalizeChannelType(type);

    setState(() => _isSending = true);
    try {
      // Нэвтэрсэн → sendOtp нь auth header илгээж sessionId автомат буцаана
      // Нэвтрээгүй → sessionId-г bodi-д оруулах ёстой
      final otpData = await authService.sendOtp(
        normalizedChannel,
        sessionId: sessionId,
      );
      if (!mounted) return;

      // Хариунаас sessionId — хэрэв ирвэл шинэ, эс бөгөөс өмнөх
      final newSessionId =
          otpData['sessionId'] as String? ?? sessionId;

      // TEST: OTP код харуулах (бодит горимд устгах)
      final otp = otpData['otp']?.toString();
      if (otp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP код: $otp')),
        );
      }

      Navigator.pushNamed(
        context,
        widget.nextRoute,
        arguments: {
          'channel': channelLabel,
          'value': maskedValue,
          'sessionId': newSessionId,
          ...?widget.extraArgs,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP илгээхэд алдаа: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
