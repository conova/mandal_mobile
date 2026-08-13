import 'package:flutter/material.dart';
import '../models/education_guide.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';

/// Зааврын нэг сэдвийн дэлгэрэнгүй агуулга.
///
/// Route args: `{'section': GuideSection?, 'item': GuideItem}`
class EducationGuideDetailScreen extends StatefulWidget {
  const EducationGuideDetailScreen({super.key});

  @override
  State<EducationGuideDetailScreen> createState() => _EducationGuideDetailScreenState();
}

class _EducationGuideDetailScreenState extends State<EducationGuideDetailScreen> {
  GuideSection? _section;
  int _currentIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize section and current index from route arguments if not already done
    if (_currentIndex == -1) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? const {};
      _section = args['section'] as GuideSection?;
      final item = args['item'] as GuideItem?;

      if (_section != null && item != null) {
        _currentIndex = _section!.items.indexWhere(
          (i) => i.title == item.title && i.body == item.body,
        );
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_section == null || _section!.items.isEmpty) return;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -500) {
      // Swipe Left -> Next Item
      if (_currentIndex < _section!.items.length - 1) {
        setState(() => _currentIndex++);
      }
    } else if (velocity > 500) {
      // Swipe Right -> Prev Item
      if (_currentIndex > 0) {
        setState(() => _currentIndex--);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final lang = Localizations.localeOf(context).languageCode;

    final item = (_section != null && _currentIndex >= 0 && _currentIndex < _section!.items.length)
        ? _section!.items[_currentIndex]
        : null;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SizedBox.expand(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  if (_section != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _section!.titleOf(lang),
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
        ),
      ),
    );
  }
}
