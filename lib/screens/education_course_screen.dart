import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/education_guide.dart';
import '../services/education_progress.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_svg_icon.dart';

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
  List<EducationCourse> _courses = [];
  int _currentIndex = -1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final completed = await EducationProgress.load();
    final data = await EducationGuideData.load();
    
    if (mounted) {
      setState(() {
        _completed = completed;
        _courses = data.courses;
        _isLoading = false;
        
        // Find initial index from arguments if not set
        if (_currentIndex == -1) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final course = args?['course'] as EducationCourse?;
          if (course != null) {
            _currentIndex = _courses.indexWhere((c) => c.id == course.id);
          }
          if (_currentIndex == -1 && _courses.isNotEmpty) {
            _currentIndex = 0;
          }
        }
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_courses.isEmpty) return;
    
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -500) {
      // Swipe Left -> Next Course
      if (_currentIndex < _courses.length - 1) {
        setState(() => _currentIndex++);
      }
    } else if (velocity > 500) {
      // Swipe Right -> Prev Course
      if (_currentIndex > 0) {
        setState(() => _currentIndex--);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: extendedColors.bgBase,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final course = _currentIndex >= 0 && _currentIndex < _courses.length 
        ? _courses[_currentIndex] 
        : null;
    final lessons = course?.lessons ?? const <EducationLesson>[];
    final done = course == null ? 0 : EducationProgress.completedCount(_completed, course);

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Column(
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
                        horizontal: 12,
                        vertical: 8,
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
                          CustomSvgIcon(
                            'check_circle',
                            size: 18,
                            color: extendedColors.primaryMain,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            final result = await Navigator.pushNamed(
                              context,
                              '/education_lesson',
                              arguments: {'course': course, 'lesson': lessons[i]},
                            );
                            if (result == true) {
                              _loadData();
                            }
                          },
                        ),
                    ],
                  ),
                ),
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
                      CustomSvgIcon(
                        'check_circle',
                        size: 22,
                        color: extendedColors.primaryMain,
                      )
                    else
                      CustomSvgIcon(
                        'chevron-right',
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
