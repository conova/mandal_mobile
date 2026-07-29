import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'custom_bottom_sheet.dart';

class LogoutBottomSheet extends StatelessWidget {
  const LogoutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return CustomBottomSheet(
      title: l10n.logoutConfirmTitle,
      description: l10n.logoutConfirmDesc,
      confirmText: l10n.yesLogout,
      cancelText: l10n.back,
      icon: 'assets/images/log_out.png',
      confirmColor: Colors.red[400],
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    );
  }
}
