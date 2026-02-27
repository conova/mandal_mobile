import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';

import 'components/my_info/info_card.dart';
import 'components/my_info/my_info_back_button.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

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
      body: SingleChildScrollView(
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
            InfoCard(label: l10n.surname, value: 'Өлзий-орших'),
            InfoCard(label: l10n.firstName, value: 'Өлзийдэлгэр'),
            InfoCard(label: l10n.regNo, value: 'УП 90021312'),
            InfoCard(
              label: l10n.email,
              value: 'mndl.i@gmail.mn',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
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
              value: '80006272',
              trailing: Icon(
                Icons.edit_outlined,
                color: extendedColors.primaryMain,
                size: 18,
              ),
            ),
            InfoCard(
              label: l10n.address,
              value:
                  'Улаанбаатар, Баянзүрх, 26-р хороо, Олимп хотхон, 1001 байр, 55а тоот',
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
