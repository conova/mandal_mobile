import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/education_guide.dart';
import '../services/education_progress.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_svg_icon.dart';

/// Боловсролын дэлгэц — санхүүгийн хичээлүүд + апп ашиглах заавар.
/// Бүх агуулга `assets/data/education_guide.json`-оос уншигдана.
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  EducationGuideData? _data;

  /// Дуусгасан сэдвүүд (courseId/lessonId) — төхөөрөмжөөс уншина
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    EducationGuideData.load().then((data) {
      if (mounted) setState(() => _data = data);
    });
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
    final data = _data;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EducationHeader(l10n: l10n),
                  const SizedBox(height: 8),
                  ...data.courses.map(
                    (c) => _CourseTile(
                      course: c,
                      done: EducationProgress.completedCount(_completed, c),
                      lang: lang,
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          '/education_course',
                          arguments: {'course': c},
                        );
                        _loadProgress();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: extendedColors.neutral500, height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appGuideTitle,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: extendedColors.neutral100,
                          ),
                        ),
                        const SizedBox(height: 24),
                        for (final section in data.sections) ...[
                          _GuideSectionView(section: section, lang: lang),
                          if (section != data.sections.last)
                            const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Градиент дэвсгэртэй толгой — back товч, зураг, гарчиг, тайлбар.
class _EducationHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _EducationHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            extendedColors.primaryMain.withValues(alpha: 0.55),
            extendedColors.bgBase,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: CircleBackButton(),
              ),
              // Гарчиг зургийн зүүн талд — доод ирмэгээрээ зэрэгцэнэ
              Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 110,),
                          Text(
                            l10n.educationTitle,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: extendedColors.neutral100,
                            ),
                          ),
                        ]
                      )
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                      child: Image.asset(
                        'assets/images/edu_intro.png',
                        height: 149,
                        errorBuilder: (_, _, _) => const SizedBox(height: 80),
                      ),
                  )
                ],
              ),
              /*Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      l10n.educationTitle,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Толгойн чимэглэл зураг (байхгүй бол юу ч харуулахгүй)
                  Image.asset(
                    'assets/images/edu_intro.png',
                    height: 149,
                    errorBuilder: (_, _, _) => const SizedBox(height: 80),
                  ),
                ],
              ),*/
              const SizedBox(height: 8),
              Text(
                l10n.educationSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: AppTextStyles.light,
                  color: extendedColors.neutral100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final EducationCourse course;
  final int done;
  final String lang;
  final VoidCallback onTap;
  const _CourseTile({
    required this.course,
    required this.done,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                course.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.menu_book_outlined,
                  color: extendedColors.primaryMain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.titleOf(lang),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppTextStyles.regular,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Явцтай (эхэлсэн) хичээл — ногоон check + тод тоо,
                  // эхлээгүй бол саарал
                  Row(
                    children: [
                      CustomSvgIcon(
                        'check_circle',
                        size: 16,
                        color: done > 0
                            ? extendedColors.primaryMain
                            : extendedColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.eduLessonProgress(done, course.total),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: AppTextStyles.regular,
                          color: done > 0
                              ? extendedColors.neutral100
                              : extendedColors.neutral200,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomSvgIcon('chevron-right', color: extendedColors.neutral300),
          ],
        ),
      ),
    );
  }
}

class _GuideSectionView extends StatelessWidget {
  final GuideSection section;
  final String lang;
  const _GuideSectionView({required this.section, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    // Education дэлгэц дээр эхний 3 сэдвийг л харуулна
    final topItems = section.items.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.titleOf(lang),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section.descriptionOf(lang),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppTextStyles.light,
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(color: extendedColors.primaryMain),
                  child: CustomSvgIcon(section.icon, size: 24),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < topItems.length; i++)
          GuideItemRow(
            index: i + 1,
            item: topItems[i],
            lang: lang,
            onTap: () => Navigator.pushNamed(
              context,
              '/education_guide_detail',
              arguments: {'section': section, 'item': topItems[i]},
            ),
          ),
        const SizedBox(height: 8),
        CustomButton(
          label: l10n.viewMore,
          variant: CustomButtonVariant.tertiary,
          onPressed: () => Navigator.pushNamed(
            context,
            '/education_guide_list',
            arguments: {'section': section},
          ),
        ),
      ],
    );
  }
}

/// Зааврын нэг мөр — дугаар нь label-аас тусдаа тул урт текст
/// мөр шилжихэд дугаарын доор орохгүй. List дэлгэц дээр мөн ашиглагдана.
class GuideItemRow extends StatelessWidget {
  final int index;
  final GuideItem item;
  final String lang;
  final VoidCallback onTap;

  const GuideItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$index.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral100,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.titleOf(lang),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: AppTextStyles.light,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CustomSvgIcon(
              'chevron-right',
              size: 20,
              color: extendedColors.neutral300,
            ),
          ],
        ),
      ),
    );
  }
}
