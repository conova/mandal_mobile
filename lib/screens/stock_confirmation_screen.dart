import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';

class StockConfirmationScreen extends StatefulWidget {
  const StockConfirmationScreen({super.key});

  @override
  State<StockConfirmationScreen> createState() =>
      _StockConfirmationScreenState();
}

class _StockConfirmationScreenState extends State<StockConfirmationScreen>
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
    _expandController.value =
        (_expandController.value + delta).clamp(0.0, 1.0);
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

    return Scaffold(
      backgroundColor: extendedColors.primaryMain,
      body: AnimatedBuilder(
        animation: Listenable.merge([_expandController, _successController]),
        builder: (context, child) {
          final expandedHeight =
              bottomSheetHeight + maxDragDistance * _expandController.value;

          return Stack(
            children: [
              // White confirmation content with bottom border radius
              Positioned.fill(
                bottom: bottomSheetHeight,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'MNDL',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: extendedColors.neutral100,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Мандал даатгал ХК',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: extendedColors.neutral300,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildConfirmationDetails(
                              theme: theme,
                              l10n: l10n,
                              extendedColors: extendedColors,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Draggable teal overlay
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
    );
  }

  Widget _buildConfirmationDetails({
    required ThemeData theme,
    required AppLocalizations l10n,
    required ExtendedColors extendedColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(theme, extendedColors, l10n.orderTypeLabel, l10n.limitPrice),
        const SizedBox(height: 16),
        _buildDetailRow(theme, extendedColors, l10n.quantityLabel, '1,000'),
        const SizedBox(height: 16),
        _buildDetailRow(theme, extendedColors, l10n.unitPrice, '62.00₮'),
        const SizedBox(height: 16),
        _buildDetailRow(
          theme,
          extendedColors,
          '${l10n.commissionLabel} (0.1%)',
          '12,132₮',
        ),
        const SizedBox(height: 24),
        // Dotted divider
        LayoutBuilder(
          builder: (context, constraints) {
            const dashWidth = 4.0;
            const dashSpace = 4.0;
            final dashCount =
                (constraints.maxWidth / (dashWidth + dashSpace)).floor();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: extendedColors.neutral400),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalPaymentLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: extendedColors.neutral300,
              ),
            ),
            Text(
              '65,520.23₮',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    ExtendedColors extendedColors,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral300,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: extendedColors.neutral100,
          ),
        ),
      ],
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
                  l10n.orderRegistered,
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
                  l10n.orderPlacedDesc,
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
