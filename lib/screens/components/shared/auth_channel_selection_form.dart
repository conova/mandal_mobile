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
    if (sessionId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Session ID байхгүй байна';
      });
      return;
    }

    try {
      final authService = context.read<AuthService>();
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

    if (sessionId != null) {
      // OTP илгээх
      setState(() => _isSending = true);
      try {
        final otpData = await authService.sendOtp(
          sessionId,
          _normalizeChannelType(type),
        );
        if (mounted) {
          // send_otp хариунаас шинэ sessionId авна
          final newSessionId = otpData['sessionId'] as String? ?? sessionId;

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
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP илгээхэд алдаа: ${e.toString().replaceFirst("Exception: ", "")}'),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSending = false);
      }
    } else {
      // sessionId байхгүй бол шууд шилжих (хуучин flow)
      Navigator.pushNamed(
        context,
        widget.nextRoute,
        arguments: {
          'channel': channelLabel,
          'value': maskedValue,
          ...?widget.extraArgs,
        },
      );
    }
  }
}
