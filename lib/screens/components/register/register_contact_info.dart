import 'package:flutter/material.dart';

class RegisterContactInfo extends StatelessWidget {
  const RegisterContactInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Та байгууллагаар бүртгүүлэх бол',
          style: TextStyle(color: theme.disabledColor, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: const Text(
                'info@mandal.capital',
                style: TextStyle(
                  color: Color(0xFF1E8675),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'хаягт хүсэлтээ илгээнэ үү.',
              style: TextStyle(color: theme.disabledColor, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
