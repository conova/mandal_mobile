import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/education_guide.dart';
import '../services/education_progress.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';

/// Хичээлийн сэдвүүдийн жагсаалт — дуусгасан сэдвүүд ногоон дэвсгэртэй,
/// баруун дээд буланд явцын товч (2/5) харагдана.
///
/// Route args: `{'course': EducationCourse}`
class EducationCourseScreen extends StatefulWidget {
  const EducationCourseScreen({super.key});

  @override
  State<EducationCourseScreen> createState() => _EducationCourseScreenState();
}

class _EducationCourseScreenState extends State<EducationCourseScreen> {
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await EducationProgress.load();
    if (mounted) setState(() => _completed = completed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final course = args['course'] as EducationCourse?;
    final lessons = course?.lessons ?? const <EducationLesson>[];
    final done =
        course == null ? 0 : EducationProgress.completedCount(_completed, course);

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    const CircleBackButton(),
                    const Spacer(),
                    // Явцын товч — 2/5 + check
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.eduLessonProgress(done, lessons.length),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: AppTextStyles.regular,
                              color: extendedColors.neutral100,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: extendedColors.primaryMain,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  course?.titleOf(lang) ?? '',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: extendedColors.neutral100,
                  ),
                ),
              ),
              for (var i = 0; i < lessons.length; i++)
                _LessonRow(
                  index: i + 1,
                  lesson: lessons[i],
                  lang: lang,
                  isCompleted: course != null &&
                      EducationProgress.isCompleted(
                        _completed,
                        course.id,
                        lessons[i].id,
                      ),
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      '/education_lesson',
                      arguments: {'course': course, 'lesson': lessons[i]},
                    );
                    _loadProgress();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final int index;
  final EducationLesson lesson;
  final String lang;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LessonRow({
    required this.index,
    required this.lesson,
    required this.lang,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Material(
      // Дуусгасан сэдэв — цайвар ногоон дэвсгэр
      color: isCompleted ? extendedColors.primary100 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$index.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: AppTextStyles.regular,
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        lesson.titleOf(lang),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: AppTextStyles.regular,
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCompleted)
                      Icon(
                        Icons.check_circle,
                        size: 22,
                        color: extendedColors.primaryMain,
                      )
                    else
                      Icon(
                        Icons.chevron_right,
                        size: 22,
                        color: extendedColors.neutral300,
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: extendedColors.neutral500),
            ],
          ),
        ),
      ),
    );
  }
}
