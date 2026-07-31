import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import 'custom_bottom_description_sheet.dart';
import 'custom_svg_icon.dart';

class CustomInfoPopupBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final ExtendedColors extendedColors;
  final AppLocalizations l10n;
  final String? icon;

  const CustomInfoPopupBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.extendedColors,
    required this.l10n,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => CustomBottomDescriptionSheet(
          title: title,
          description: description,
          cancelText: l10n.close,
          onCancel: () => Navigator.pop(ctx),
          icon: icon,
        ),
      ),
      child: CustomSvgIcon('info-circle', size: 20, color: extendedColors.neutral300,),
    );
  }
}