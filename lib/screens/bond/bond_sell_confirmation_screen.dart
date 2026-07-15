import 'package:flutter/material.dart';
import '../components/bond/bond_confirmation_details.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';

class BondSellConfirmationScreen extends StatefulWidget {
  const BondSellConfirmationScreen({super.key});

  @override
  State<BondSellConfirmationScreen> createState() =>
      _BondSellConfirmationScreenState();
}

class _BondSellConfirmationScreenState extends State<BondSellConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _contentFadeAnimation;

  late AnimationController _successController;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _descFadeAnimation;
  late Animation<Offset> _descSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  bool _isConfirming = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _contentFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _expandController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isConfirming) {
        setState(() => _showSuccess = true);
        _successController.forward();
      }
    });

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _successController,
            curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
          ),
        );

    _descFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );
    _descSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _successController,
            curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
          ),
        );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _successController,
            curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDragDistance) {
    if (_isConfirming) return;
    final delta = -details.delta.dy / maxDragDistance;
    _expandController.value = (_expandController.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isConfirming) return;

    if (_expandController.value > 0.4) {
      _isConfirming = true;
      _expandController.forward();
    } else {
      _expandController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final screenHeight = MediaQuery.of(context).size.height;
    const bottomSheetHeight = 120.0;
    final maxDragDistance = screenHeight - bottomSheetHeight;

    return PopScope(
      // Захиалга баталгаажиж эхэлсний дараа буцах боломжгүй — эс бөгөөс
      // өмнөх дэлгэц рүү орж захиалгаа давхардуулж илгээх эрсдэлтэй
      canPop: !_isConfirming,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showSuccess) {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
        }
      },
      child: Scaffold(
        backgroundColor: extendedColors.primaryMain,
        body: AnimatedBuilder(
          animation: Listenable.merge([_expandController, _successController]),
          builder: (context, child) {
            final expandedHeight =
                bottomSheetHeight + maxDragDistance * _expandController.value;

            return Stack(
              children: [
                Positioned.fill(
                  bottom: bottomSheetHeight,
                  // Баталгаажуулж эхэлсний дараа бүдгэрсэн контент (back товч
                  // орно) дарагдахгүй байх ёстой
                  child: IgnorePointer(
                    ignoring: _isConfirming,
                    child: Opacity(
                      opacity: _contentFadeAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: extendedColors.bgBase,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: extendedColors.bgSecondary,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: extendedColors.neutral100,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Net Capital',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: extendedColors.neutral100,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        'Нэт Капитал',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: extendedColors.neutral300,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 48),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: BondConfirmationDetails(
                                  name: 'Net Capital',
                                  type: l10n.closed,
                                  quantity: '10',
                                  unitPrice: '991,000₮',
                                  commission: '5,000₮',
                                  total: '9,915,000₮',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: expandedHeight,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) =>
                        _onDragUpdate(details, maxDragDistance),
                    onVerticalDragEnd: _onDragEnd,
                    child: Container(
                      decoration: BoxDecoration(
                        color: extendedColors.primaryMain,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            32 * (1 - _expandController.value),
                          ),
                          topRight: Radius.circular(
                            32 * (1 - _expandController.value),
                          ),
                        ),
                      ),
                      child: _showSuccess
                          ? _buildSuccessContent(theme, l10n, extendedColors)
                          : Opacity(
                              opacity: _contentFadeAnimation.value,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.keyboard_double_arrow_up,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.swipeUpToConfirm,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessContent(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            ScaleTransition(
              scale: _checkScaleAnimation,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: extendedColors.primaryMain,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 64),
            FadeTransition(
              opacity: _titleFadeAnimation,
              child: SlideTransition(
                position: _titleSlideAnimation,
                child: Text(
                  l10n.orderPlacedSuccess,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _descFadeAnimation,
              child: SlideTransition(
                position: _descSlideAnimation,
                child: Text(
                  l10n.sellOrderSuccessDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Spacer(),
            FadeTransition(
              opacity: _buttonFadeAnimation,
              child: SlideTransition(
                position: _buttonSlideAnimation,
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main',
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      l10n.viewOrders,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: extendedColors.neutral100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
