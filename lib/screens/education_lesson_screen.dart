import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../l10n/app_localizations.dart';
import '../models/education_guide.dart';
import '../services/education_progress.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_svg_icon.dart';

/// Хичээлийн сэдвийн агуулга — слайдуудаар үзээд төгсгөлд нь
/// мэдлэг шалгах тест бөглөнө. Зөв хариулбал сэдэв дуусгасанд
/// тооцогдож төхөөрөмжид хадгалагдана.
///
/// Route args: `{'course': EducationCourse, 'lesson': EducationLesson}`
class EducationLessonScreen extends StatefulWidget {
  const EducationLessonScreen({super.key});

  @override
  State<EducationLessonScreen> createState() => _EducationLessonScreenState();
}

class _EducationLessonScreenState extends State<EducationLessonScreen> {
  int _index = 0;
  bool _showQuiz = false;

  /// Тестийн сонгосон хариулт (null — хараахан сонгоогүй)
  int? _selected;

  /// "Хариулт шалгах" товч дарж хариултаа шалгуулсан эсэх
  bool _answered = false;

  EducationCourse? get _course =>
      (ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?)?['course'] as EducationCourse?;

  EducationLesson? get _lesson =>
      (ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?)?['lesson'] as EducationLesson?;

  Future<void> _finish() async {
    final course = _course;
    final lesson = _lesson;
    if (course != null && lesson != null) {
      await EducationProgress.markCompleted(course.id, lesson.id);
    }
    if (mounted) Navigator.pop(context, true);
  }

  void _next(int slideCount, bool hasQuiz) {
    if (_index < slideCount - 1) {
      setState(() => _index++);
    } else if (hasQuiz) {
      setState(() => _showQuiz = true);
    } else {
      // Тестгүй сэдэв — сүүлийн слайд дээр шууд дуусгана
      _finish();
    }
  }

  void _back() {
    if (_showQuiz) {
      setState(() {
        _showQuiz = false;
        _selected = null;
        _answered = false;
      });
    } else if (_index > 0) {
      setState(() => _index--);
    } else {
      Navigator.pop(context);
    }
  }

  /// Буруу хариулсны дараа — сэдвийг эхнээс нь дахин үзэх
  void _retry() {
    setState(() {
      _index = 0;
      _showQuiz = false;
      _selected = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final lang = Localizations.localeOf(context).languageCode;

    final lesson = _lesson;
    final slides = lesson?.slides ?? const <LessonSlide>[];
    final quiz = lesson?.quiz;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -500) {
              // Swipe Left -> Next
              if (!_showQuiz) {
                _next(slides.length, quiz != null);
              }
            } else if (velocity > 500) {
              // Swipe Right -> Back
              _back();
            }
          },
          child: Column(
            children: [
              // Хаах товч
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _CircleIconButton(
                    icon: 'x-icon',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: _showQuiz && quiz != null
                    ? _QuizView(
                  quiz: quiz,
                  lang: lang,
                  totalSteps: slides.length + 1,
                  selected: _selected,
                  answered: _answered,
                  onSelect: (i) => setState(() => _selected = i),
                  onCheck: () => setState(() => _answered = true),
                  onBack: _back,
                  onFinish: _finish,
                  onRetry: _retry,
                  onLater: () => Navigator.pop(context),
                )
                    : slides.isEmpty
                    ? const SizedBox.shrink()
                    : _SlideView(
                  slide: slides[_index],
                  lang: lang,
                  index: _index,
                  // Тест нь сүүлийн алхам болж тоологдоно
                  total: slides.length + (quiz != null ? 1 : 0),
                  onBack: _back,
                  onNext: () => _next(slides.length, quiz != null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Саарал дугуй дэвсгэртэй icon товч (back/close)
class _CircleIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: extendedColors.bgSecondary,
          shape: BoxShape.circle,
        ),
        child: Padding(
            padding: EdgeInsets.all(8),
          child: CustomSvgIcon(icon, size: 24, color: extendedColors.neutral100),
        ),
      ),
    );
  }
}

/// Нэг слайдын агуулга + доод навигаци (явцын зураас, Дараах товч)
class _SlideView extends StatelessWidget {
  final LessonSlide slide;
  final String lang;
  final int index;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _SlideView({
    required this.slide,
    required this.lang,
    required this.index,
    required this.total,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isLast = index == total - 1;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (slide.video.isNotEmpty || slide.image.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // Бичлэг байвал тоглуулагч, үгүй бол зураг
                    child: slide.video.isNotEmpty
                        ? _SlideVideo(url: slide.video)
                        : _SlideImage(src: slide.image),
                  ),
                  if (slide.captionOf(lang).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        slide.captionOf(lang),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: AppTextStyles.light,
                          color: extendedColors.neutral300,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                Text(
                  slide.titleOf(lang),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  slide.bodyOf(lang),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Явцын зураас — үзсэн хэсэг ногооноор
        LinearProgressIndicator(
          value: (index + 1) / total,
          minHeight: 2,
          backgroundColor: extendedColors.neutral500,
          valueColor: AlwaysStoppedAnimation<Color>(extendedColors.primaryMain),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              _CircleIconButton(icon: 'close-button', onTap: onBack),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  label: isLast
                      ? l10n.eduFinish
                      : l10n.eduNextCounter(index + 1, total),
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Мэдлэг шалгах тест — хариултаа сонгоод "Хариулт шалгах" алхмын
/// товчоор шалгуулна, дараа нь үр дүн харагдана
class _QuizView extends StatelessWidget {
  final LessonQuiz quiz;
  final String lang;
  final int totalSteps;
  final int? selected;
  final bool answered;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final VoidCallback onRetry;
  final VoidCallback onLater;

  const _QuizView({
    required this.quiz,
    required this.lang,
    required this.totalSteps,
    required this.selected,
    required this.answered,
    required this.onSelect,
    required this.onCheck,
    required this.onBack,
    required this.onFinish,
    required this.onRetry,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final options = quiz.optionsOf(lang);
    final isCorrect = selected == quiz.correctIndex;
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.eduQuizLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTextStyles.regular,
                        color: extendedColors.primaryMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quiz.questionOf(lang),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (var i = 0; i < options.length; i++)
                      _OptionTile(
                        label: '${letters[i]}. ${options[i]}',
                        state: !answered
                            // Шалгахаас өмнө сонгосон хариулт зөвхөн тодорно
                            ? (i == selected
                                ? _OptionState.selected
                                : _OptionState.idle)
                            : i == quiz.correctIndex
                                ? _OptionState.correct
                                : i == selected
                                    ? _OptionState.wrong
                                    : _OptionState.idle,
                        onTap: answered ? null : () => onSelect(i),
                      ),
                  ],
                ),
              ),
              // Зөв хариулсан үед confetti цацна
              if (answered && isCorrect)
                const Positioned.fill(child: _ConfettiOverlay()),
            ],
          ),
        ),
        // Шалгахаас өмнө — слайдтай ижил алхмын навигаци
        if (!answered) ...[
          LinearProgressIndicator(
            value: 1,
            minHeight: 2,
            backgroundColor: extendedColors.neutral500,
            valueColor:
                AlwaysStoppedAnimation<Color>(extendedColors.primaryMain),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                _CircleIconButton(icon: 'close-button', onTap: onBack),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: l10n.eduCheckAnswer(totalSteps, totalSteps),
                    // Хариулт сонгоогүй бол идэвхгүй
                    onPressed: selected == null ? null : onCheck,
                  ),
                ),
              ],
            ),
          ),
        ],
        // Үр дүнгийн хэсэг — шалгасны дараа гарна
        if (answered)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: extendedColors.neutral500),
              ),
            ),
            child: Column(
              children: [
                Text(
                  isCorrect ? l10n.eduCorrectAnswer : l10n.eduWrongAnswer,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCorrect ? l10n.eduCorrectDesc : l10n.eduWrongDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 16),
                if (isCorrect)
                  CustomButton(label: l10n.eduFinish, onPressed: onFinish)
                else ...[
                  CustomButton(label: l10n.eduRetryLesson, onPressed: onRetry),
                  const SizedBox(height: 8),
                  CustomButton(
                    label: l10n.eduLater,
                    variant: CustomButtonVariant.tertiary,
                    onPressed: onLater,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final bg = switch (state) {
      _OptionState.idle => extendedColors.bgSecondary,
      _OptionState.selected ||
      _OptionState.correct =>
        extendedColors.primary100,
      _OptionState.wrong => extendedColors.red100,
    };
    final fg = switch (state) {
      _OptionState.idle => extendedColors.neutral100,
      _OptionState.selected ||
      _OptionState.correct =>
        extendedColors.primaryMain,
      _OptionState.wrong => extendedColors.red,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.regular,
                    color: fg,
                  ),
                ),
              ),
              if (state == _OptionState.correct)
                Icon(Icons.check, size: 20, color: extendedColors.primaryMain),
              if (state == _OptionState.wrong)
                Icon(Icons.close, size: 20, color: extendedColors.red),
            ],
          ),
        ),
      ),
    );
  }
}

/// Зөв хариулт өгсөн үед нэг удаа тоглох confetti анимэйшн.
/// Гадны сан ашиглалгүй CustomPainter-ээр зурна.
class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay();

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          painter: _ConfettiPainter(_controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Нэг ширхэг confetti — төвөөс тархах чиглэл, хэлбэр, өнгөтэй
class _ConfettiParticle {
  final double angle;
  final double distance; // 0..1 — дэлгэцийн хагасын хэдэн хувь хүртэл нисэх
  final double size;
  final double spin;
  final int shape; // 0 дугуй, 1 зурвас, 2 хэрээс, 3 од
  final int color;

  const _ConfettiParticle(
    this.angle,
    this.distance,
    this.size,
    this.spin,
    this.shape,
    this.color,
  );
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  _ConfettiPainter(this.t);

  static const _colors = [
    Color(0xFFFF2D9B), // ягаан
    Color(0xFFFFC700), // шар
    Color(0xFF4A9DFF), // цэнхэр
    Color(0xFFFF7A00), // улбар шар
  ];

  /// Тогтмол seed — бүх төхөөрөмж дээр ижилхэн тархалт
  static final List<_ConfettiParticle> _particles = () {
    final rng = math.Random(7);
    return List.generate(36, (i) {
      return _ConfettiParticle(
        rng.nextDouble() * 2 * math.pi,
        0.35 + rng.nextDouble() * 0.65,
        3 + rng.nextDouble() * 6,
        (rng.nextDouble() - 0.5) * 6,
        rng.nextInt(4),
        rng.nextInt(_colors.length),
      );
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final progress = Curves.easeOutCubic.transform(t);
    // Сүүлийн 30%-д аажим замхарна
    final opacity = t < 0.7 ? 1.0 : 1.0 - (t - 0.7) / 0.3;
    final radius = math.min(size.width, size.height) * 0.55;

    for (final p in _particles) {
      final pos = center +
          Offset(math.cos(p.angle), math.sin(p.angle)) *
              (p.distance * radius * progress);
      final paint = Paint()
        ..color = _colors[p.color].withValues(alpha: opacity)
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.angle + p.spin * t);

      switch (p.shape) {
        case 0: // дугуй
          canvas.drawCircle(Offset.zero, p.size * 0.7, paint);
        case 1: // нугалсан зурвас
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = p.size * 0.7;
          canvas.drawArc(
            Rect.fromCircle(center: Offset.zero, radius: p.size * 2),
            0,
            math.pi * 0.8,
            false,
            paint,
          );
        case 2: // хэрээс (x)
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = p.size * 0.5;
          canvas.drawLine(
            Offset(-p.size * 0.6, -p.size * 0.6),
            Offset(p.size * 0.6, p.size * 0.6),
            paint,
          );
          canvas.drawLine(
            Offset(p.size * 0.6, -p.size * 0.6),
            Offset(-p.size * 0.6, p.size * 0.6),
            paint,
          );
        case 3: // дөрвөн хошуут од
          final path = Path();
          final r = p.size;
          for (var i = 0; i < 8; i++) {
            final a = i * math.pi / 4;
            final len = i.isEven ? r : r * 0.4;
            final point = Offset(math.cos(a) * len, math.sin(a) * len);
            if (i == 0) {
              path.moveTo(point.dx, point.dy);
            } else {
              path.lineTo(point.dx, point.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}

/// Слайдын зураг — http(s) URL бол сүлжээнээс, бусад тохиолдолд
/// asset-аас ачаална. Олдохгүй бол юу ч харуулахгүй.
class _SlideImage extends StatelessWidget {
  final String src;
  const _SlideImage({required this.src});

  @override
  Widget build(BuildContext context) {
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;

    if (src.startsWith('http')) {
      return Image.network(
        src,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: extendedColors.bgSecondary,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }
    return Image.asset(
      src,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}

/// Слайдын бичлэг тоглуулагч — URL-ээс ачаалж, дарахад
/// тоглуулж/зогсооно. Зогссон үед play товч харагдана.
class _SlideVideo extends StatefulWidget {
  final String url;
  const _SlideVideo({required this.url});

  @override
  State<_SlideVideo> createState() => _SlideVideoState();
}

class _SlideVideoState extends State<_SlideVideo> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.initialize().then((_) {
      if (mounted) setState(() => _ready = true);
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;

    if (_failed) return const SizedBox.shrink();

    if (!_ready) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: extendedColors.bgSecondary,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: GestureDetector(
        onTap: () {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            // Зогссон үед play товч
            ListenableBuilder(
              listenable: _controller,
              builder: (_, _) => _controller.value.isPlaying
                  ? const SizedBox.shrink()
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 36,
                        color: Colors.black87,
                      ),
                    ),
            ),
            // Явцын зураас — бичлэгийн доод хэсэгт
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: extendedColors.primaryMain,
                  bufferedColor: Colors.white54,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
