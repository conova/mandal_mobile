import 'package:flutter/material.dart';
import '../../../theme/extended_colors.dart';

class RegisterContactInfo extends StatelessWidget {
  const RegisterContactInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Та байгууллагаар бүртгүүлэх бол',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral200,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text(
                'info@mandal.capital',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral100,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'хаягт хүсэлтээ илгээнэ үү.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
