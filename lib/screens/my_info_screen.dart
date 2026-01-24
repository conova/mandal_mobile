import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../widgets/info_card.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
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
                fontSize: 28,
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
                  Icon(Icons.verified_user_outlined, color: Colors.orange[300], size: 18),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined, color: theme.primaryColor, size: 18),
                ],
              ),
            ),
            InfoCard(
              label: l10n.phoneNumber,
              value: '80006272',
              trailing: Icon(Icons.edit_outlined, color: theme.primaryColor, size: 18),
            ),
            InfoCard(
              label: l10n.address,
              value: 'Улаанбаатар, Баянзүрх, 26-р хороо, Олимп хотхон, 1001 байр, 55а тоот',
              trailing: Icon(Icons.edit_outlined, color: theme.primaryColor, size: 18),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
