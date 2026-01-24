import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final bool isPrimary;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.bankName,
    required this.accountNumber,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? Border.all(color: theme.primaryColor.withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountNumber,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bankName,
                    style: TextStyle(color: theme.disabledColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }
}
