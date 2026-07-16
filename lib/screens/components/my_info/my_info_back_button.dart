import 'package:flutter/material.dart';

import '../../../widgets/custom_svg_icon.dart';

class MyInfoBackButton extends StatelessWidget {
  const MyInfoBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: IconButton(
          icon: const CustomSvgIcon('close-button', size: 24),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
