import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../services/auth_service.dart';

import 'components/my_info/info_card.dart';
import 'components/my_info/my_info_back_button.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Дэлгэц нээгдэхэд background-д шинэчилнэ.
    // Хэрэв cache байхгүй бол build()-д loader харагдана; мэдээлэл ирэхэд
    // notifyListeners()-р дамжаад автомат шинэчлэгдэнэ.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthService>().refreshUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;

    // Cache-аас шууд авах. Хоосон бол loader харагдана.
    final userInfo = context.watch<AuthService>().userInfo;
    final isLoading = userInfo == null;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const MyInfoBackButton(),
      ),
      body: isLoading
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
                    value: userInfo['lastName']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.firstName,
                    value: userInfo['firstName']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.regNo,
                    value: userInfo['registerNumber']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.email,
                    value: userInfo['email']?.toString() ?? '-',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (userInfo['emailVerified'] == true)
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
                    value: userInfo['phone']?.toString() ?? '-',
                    trailing: Icon(
                      Icons.edit_outlined,
                      color: extendedColors.primaryMain,
                      size: 18,
                    ),
                  ),
                  InfoCard(
                    label: l10n.address,
                    value: userInfo['address']?.toString() ?? '-',
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
