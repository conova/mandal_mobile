import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class AccruedInterestDescBottomSheet extends StatelessWidget {
  final CustomButtonVariant? buttonVariant;

  const AccruedInterestDescBottomSheet({
    super.key,
    this.buttonVariant
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: extendedColors.bgBase,
          boxShadow: [
            BoxShadow(
              color: extendedColors.neutral400,
              offset: Offset(0, -4),
              blurRadius: 40,
            )
          ]
      ),
      // Жижиг дэлгэц/keyboard үед агуулга багтахгүй бол scroll болно
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: extendedColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.accruedInterest,
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100
              ),
            ),
            const SizedBox(height: 32),
            const _InterestDiagram(),
            const SizedBox(height: 32),
            Text(
              l10n.accruedInterestDescP1,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w200,
                color: extendedColors.neutral100,
              ),
            ),
            const SizedBox(height: 20,),
            Text(
              l10n.accruedInterestDescP2,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w200,
                color: extendedColors.neutral100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.accruedInterestDescP3,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w200,
                color: extendedColors.neutral100,
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: CustomButton(
                label: l10n.returnBack,
                onPressed: () => Navigator.pop(context),
                variant: buttonVariant ?? CustomButtonVariant.tertiary,
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class _InterestDiagram extends StatelessWidget {
  const _InterestDiagram();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    // The whole diagram (top labels + bar + gradient + bracket) is built
    // from a single LayoutBuilder so every element that needs to line up
    // with the separator (the purchase date) uses the SAME redWidth value.
    // Previously the top "Өнөөдөр" label was centered via Row/Expanded
    // (always at 50% width) while the separator marker sat at redWidth
    // (35% width) — they only lined up by coincidence. Now both are
    // Positioned at the identical x offset.
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      const markerSize = 12.0;
      const markerHaloSize = 18.0;
      const redRatio = 0.35;
      final redWidth = width * redRatio;
      final separatorCenterX = redWidth; // single source of truth

      return Column(
        children: [
          // ---- Top label row, built with Positioned instead of
          // Row/Expanded so the center label can be pinned exactly at
          // separatorCenterX rather than at 50% of the width. ----
          SizedBox(
            height: 46,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 8,
                  child: Text(
                    l10n.prevInterestPaidDate,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: extendedColors.neutral100,
                      fontSize: 10,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 8,
                  child: Text(
                    l10n.nextInterestPayDueDate,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: extendedColors.neutral100,
                      fontSize: 10,
                    ),
                  ),
                ),
                // Center label + arrow, pinned exactly above the
                // separator marker via a FractionalTranslation of -50%,
                // keeping it centered ON separatorCenterX regardless of
                // text length/locale.
                Positioned(
                  left: separatorCenterX,
                  top: 0,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.1),
                    child: Column(
                      children: [
                        Text(
                          l10n.todayBondBuyDate,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: extendedColors.primaryMain,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomSvgIcon(
                          'arrow-down',
                          size: 16,
                          color: extendedColors.primaryMain,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient fills, flush with the timeline.
              Padding(
                padding: const EdgeInsets.only(top: markerSize),
                child: Row(
                  children: [
                    Container(
                      width: redWidth,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            extendedColors.red.withOpacity(0.18),
                            extendedColors.red.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              extendedColors.primaryMain.withOpacity(0.14),
                              extendedColors.primaryMain.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: markerHaloSize,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned(
                        left: markerHaloSize / 2,
                        width: redWidth - markerHaloSize,
                        child: Container(height: 2, color: extendedColors.red),
                      ),
                      Positioned(
                        left: redWidth + markerHaloSize / 2,
                        right: markerHaloSize / 2,
                        child: CustomPaint(
                          painter: _DottedLinePainter(color: extendedColors.primaryMain),
                          size: const Size.fromHeight(2),
                        ),
                      ),
                      _MarkerWithHalo(
                        left: 0,
                        color: extendedColors.red,
                        markerSize: markerSize,
                        haloSize: markerHaloSize,
                      ),
                      _MarkerWithHalo(
                        left: width - markerHaloSize,
                        color: extendedColors.primaryMain,
                        markerSize: markerSize,
                        haloSize: markerHaloSize,
                      ),
                      // Separator marker — its left edge is derived from
                      // the exact same separatorCenterX used for the top
                      // label above, so the two can never drift apart.
                      _MarkerWithHalo(
                        left: separatorCenterX - markerHaloSize / 2,
                        color: extendedColors.primaryMain,
                        markerSize: markerSize,
                        haloSize: markerHaloSize,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: markerHaloSize + 16,
                left: 8,
                width: redWidth,
                child: Text(
                  l10n.accruedInterestToSeller,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: extendedColors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomPaint(
            painter: _BracketPainter(color: extendedColors.primaryMain),
            size: Size(width, 16),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.yourInterestToReceive,
            style: theme.textTheme.labelLarge?.copyWith(
              color: extendedColors.neutral100,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    });
  }
}

/// A colored square marker with a white "halo" behind it so it reads
/// clearly against the gradient fill and dashed line beneath.
class _MarkerWithHalo extends StatelessWidget {
  const _MarkerWithHalo({
    required this.left,
    required this.color,
    required this.markerSize,
    required this.haloSize,
  });

  final double left;
  final Color color;
  final double markerSize;
  final double haloSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: haloSize,
        height: haloSize,
        color: Colors.white,
        alignment: Alignment.center,
        child: Container(
          width: markerSize,
          height: markerSize,
          color: color,
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4;
    const dashSpace = 2;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2), Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = size.width;
    final h = size.height;
    const r = 8.0;

    path.moveTo(0, 0);
    path.lineTo(0, h / 2 - r);
    path.quadraticBezierTo(0, h / 2, r, h / 2);
    path.lineTo(w / 2 - r, h / 2);
    path.quadraticBezierTo(w / 2, h / 2, w / 2, h / 2 + r);
    path.moveTo(w / 2, h / 2 + r);
    path.quadraticBezierTo(w / 2, h / 2, w / 2 + r, h / 2);
    path.lineTo(w - r, h / 2);
    path.quadraticBezierTo(w, h / 2, w, h / 2 - r);
    path.lineTo(w, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}