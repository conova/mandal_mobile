import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

import 'components/my_info/info_card.dart';
import 'components/my_info/my_info_back_button.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(ApiConfig.userInfo);
      final body = response.data;

      if (mounted && body['code']?.toString() == '0' && body['data'] != null) {
        setState(() {
          _userInfo = body['data'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const MyInfoBackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.myInfo,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  InfoCard(
                    label: l10n.surname,
                    value: _userInfo?['lastName']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.firstName,
                    value: _userInfo?['firstName']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.regNo,
                    value: _userInfo?['registerNumber']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.email,
                    value: _userInfo?['email']?.toString() ?? '-',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_userInfo?['emailVerified'] == true)
                          Icon(
                            Icons.verified_user_outlined,
                            color: extendedColors.primaryMain,
                            size: 18,
                          )
                        else
                          Icon(
                            Icons.warning_amber_outlined,
                            color: extendedColors.orange,
                            size: 18,
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit_outlined,
                          color: extendedColors.primaryMain,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  InfoCard(
                    label: l10n.phoneNumber,
                    value: _userInfo?['phone']?.toString() ?? '-',
                    trailing: Icon(
                      Icons.edit_outlined,
                      color: extendedColors.primaryMain,
                      size: 18,
                    ),
                  ),
                  InfoCard(
                    label: l10n.address,
                    value: _userInfo?['address']?.toString() ?? '-',
                    trailing: Icon(
                      Icons.edit_outlined,
                      color: extendedColors.primaryMain,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
