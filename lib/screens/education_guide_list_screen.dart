import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/education_guide.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_svg_icon.dart';
import 'education_screen.dart' show GuideItemRow;

/// Зааврын бүлгийн бүх сэдвийн жагсаалт — түлхүүр үгээр хайх боломжтой.
///
/// Route args: `{'section': GuideSection}`
class EducationGuideListScreen extends StatefulWidget {
  const EducationGuideListScreen({super.key});

  @override
  State<EducationGuideListScreen> createState() =>
      _EducationGuideListScreenState();
}

class _EducationGuideListScreenState extends State<EducationGuideListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final section = args['section'] as GuideSection?;
    final items = section?.items ?? const <GuideItem>[];

    // Түлхүүр үгээр шүүнэ (гарчиг + агуулгаас хайна)
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items
            .where((e) =>
                e.titleOf(lang).toLowerCase().contains(q) ||
                e.bodyOf(lang).toLowerCase().contains(q))
            .toList();

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            section?.titleOf(lang) ?? '',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Хайлтын талбар
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchByKeyword,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral300,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 8),
                    child: CustomSvgIcon(
                      'search-icon',
                      color: extendedColors.neutral200,
                    ),
                  ),
                  filled: true,
                  fillColor: extendedColors.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14,),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (context, i) => GuideItemRow(
                  index: i + 1,
                  item: filtered[i],
                  lang: lang,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/education_guide_detail',
                    arguments: {'section': section, 'item': filtered[i]},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
