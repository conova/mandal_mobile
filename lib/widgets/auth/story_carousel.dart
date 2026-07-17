import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/extended_colors.dart';
import '../logo.dart';

class StoryCarousel extends StatefulWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;
  final VoidCallback onClose;

  const StoryCarousel({
    super.key,
    required this.onLoginPressed,
    required this.onRegisterPressed,
    required this.onClose,
  });

  @override
  State<StoryCarousel> createState() => _StoryCarouselState();
}

class _StoryCarouselState extends State<StoryCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  double _progress = 0;
  static const int _slideDuration = 5; // seconds per slide

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/bank_building.png',
      'title': 'Технологид суурилсан хөрөнгө оруулалтын банк',
      'subtitle':
          'Бонд, хувьцаа хөрөнгө оруулалт болон брокерийн зөвлөх үйлчилгээг Мандал Капитал-аас.',
    },
    {
      'image': 'assets/images/bar_chart.png',
      'title': 'Тогтмол өгөөжтэй бонд жилийн 18–20 % хүүтэй',
      'subtitle':
          '3 сар тутамд өгөөжөө авч, хүссэн үедээ зарах боломжтой бонд. Яг л таны мэдэх хугацаагүй хадгаламж шиг.',
    },
    {
      'image': 'assets/images/story_handshaking.png',
      'title': 'Хөрөнгө оруулалтын аялалаа эхэлцгээе',
      'subtitle':
          'Таны зорилго, бидний туршлага - итгэл, өгөөж, боломжоор дүүрэн байна гэдэгт итгэлтэй байна.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_progress < 1) {
          _progress += 0.05 / _slideDuration;
        } else {
          _nextSlide();
        }
      });
    });
  }

  void _nextSlide() {
    if (_currentIndex < _slides.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startTimer();
    } else {
      _timer?.cancel();
      // Optionally loops or closes. For stories, usually we stay on last or close.
      // Let's loop for now to keep it alive.
      _currentIndex = 0;
      _pageController.jumpToPage(0);
      _startTimer();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    return Scaffold(
      backgroundColor: Colors.black, // Story aesthetic is usually black
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // Background Image (Splash Screen)
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_screen.png',
                fit: BoxFit.cover,
              ),
            ),
            // Background PageView
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _startTimer();
                });
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return _buildSlide(slide);
              },
            ),

            // Progress Bars
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: List.generate(_slides.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: index == _currentIndex
                                ? _progress
                                : (index < _currentIndex ? 1.0 : 0.0),
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Logo (Optional, based on image)
            Positioned(
              top: MediaQuery.of(context).padding.top + 25,
              left: 20,
              child: Row(
                children: [
                  // Simplified logo for carousel
                  const AppLogo(width: 32, height: 32, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Мандал Капитал',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTextStyles.semiBold,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Buttons
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  _buildStoryButton(
                    label: 'Бүртгүүлэх',
                    onPressed: widget.onRegisterPressed,
                    backgroundColor: extendedColors.primaryMain,
                    textColor: Colors.black,
                  ),
                  const SizedBox(height: 12),
                  _buildStoryButton(
                    label: 'Нэвтрэх',
                    onPressed: widget.onLoginPressed,
                    backgroundColor: extendedColors.primary100,
                    textColor: extendedColors.primaryMain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryButton({
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(26),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: AppTextStyles.regular,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(Map<String, String> slide) {
    final theme = Theme.of(context);
    final bool isHandshake =
        slide['image'] == 'assets/images/story_handshaking.png';

    return Stack(
      children: [
        // Image at top: 154, height: 240
        Positioned(
          top: 184,
          left: 0,
          right: 0,
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black, Colors.transparent],
                stops: const [0.0, 0.85, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              slide['image']!,
              height: 240,
              width: double.infinity,
              fit: isHandshake ? BoxFit.fitWidth : BoxFit.contain,
            ),
          ),
        ),

        // Title content
        Positioned(
          top: 472,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 311,
              child: Text(
                slide['title']!,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTextStyles.semiBold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // Subtitle content
        Positioned(
          top: 551,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 340,
              child: Text(
                slide['subtitle']!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: AppTextStyles.extraLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
