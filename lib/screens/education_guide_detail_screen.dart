import 'package:flutter/material.dart';
import '../models/education_guide.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';

/// Зааврын нэг сэдвийн дэлгэрэнгүй агуулга.
///
/// Route args: `{'section': GuideSection?, 'item': GuideItem}`
class EducationGuideDetailScreen extends StatelessWidget {
  const EducationGuideDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final lang = Localizations.localeOf(context).languageCode;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final section = args['section'] as GuideSection?;
    final item = args['item'] as GuideItem?;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: CircleBackButton(),
              ),
              const SizedBox(height: 24),
              // Бүлгийн нэр — жижиг ногоон текст
              if (section != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    section.titleOf(lang),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppTextStyles.regular,
                      color: extendedColors.primaryMain,
                    ),
                  ),
                ),
              Text(
                item?.titleOf(lang) ?? '',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item?.bodyOf(lang) ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: AppTextStyles.light,
                  color: extendedColors.neutral100,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
