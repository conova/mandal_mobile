import 'package:flutter/material.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';

/// Notification дэлгэрэнгүй харах дэлгэц.
///
/// Args:
///   {
///     'title': String,
///     'body': String,
///     'time': String,
///     'icon': IconData? (default: notifications_none_outlined),
///   }
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final title = (args['title'] as String?) ?? '';
    final body = (args['body'] as String?) ?? '';
    final time = (args['time'] as String?) ?? '';
    final icon =
        (args['icon'] as IconData?) ?? Icons.notifications_none_outlined;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Body
                    Text(
                      body,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral100,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Time
                    Text(
                      time,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Footer button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: CustomButton(
                label: 'Буцах',
                onPressed: () => Navigator.pop(context),
                variant: CustomButtonVariant.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
