import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import 'contracts_screen.dart' show ContractDoc, ContractSectionScreen;

/// Үнэт цаасны гэрээ — KYC-ийн алхам. 3 үе шаттай:
///   1/3 — "Мөнгөн хөрөнгийн гүйлгээ хийх гэрээ"-г зөвшөөрөх
///   2/3 — "Дотоод арилжааны данс нээх, номинал дансны гэрээ"-г зөвшөөрөх
///   3/3 — Гарын үсэг зурж баталгаажуулах (sign type-оор upload хийнэ)
class SecuritiesAgreementScreen extends StatefulWidget {
  const SecuritiesAgreementScreen({super.key});

  @override
  State<SecuritiesAgreementScreen> createState() =>
      _SecuritiesAgreementScreenState();
}

class _SecuritiesAgreementScreenState extends State<SecuritiesAgreementScreen> {
  int _step = 1;
  bool _agreed = false;
  bool _isSubmitting = false;

  List<ContractDoc> _contracts = const [];
  final ScrollController _scrollController = ScrollController();

  /// Гарын үсгийн зурлагууд (гар хөдөлгөөн бүр нэг stroke)
  final List<List<Offset>> _strokes = [];
  final GlobalKey _signBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContracts() async {
    try {
      final raw = await rootBundle.loadString('assets/data/contracts.json');
      final body = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _contracts = (body['contracts'] as List? ?? const [])
            .whereType<Map>()
            .map((c) => ContractDoc.fromJson(Map<String, dynamic>.from(c)))
            .toList();
      });
    } catch (_) {
      // Гэрээний текст ачаалагдаагүй ч wizard ажиллана
    }
  }

  void _onBack() {
    if (_step > 1) {
      setState(() {
        _step--;
        _agreed = false;
      });
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    } else {
      Navigator.pop(context);
    }
  }

  /// Гэрээ зөвшөөрөх — дараагийн алхам руу
  void _onAgree() {
    setState(() {
      _step++;
      _agreed = false;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  /// Гарын үсгийг PNG болгож base64-ээр sign type-той upload хийнэ,
  /// дараа нь гэрээг зөвшөөрсөн төлөвт оруулна
  Future<void> _submitSignature() async {
    if (_strokes.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final boundary = _signBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Гарын үсгийг уншиж чадсангүй');
      }
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Гарын үсгийг хөрвүүлж чадсангүй');
      }
      final base64Image = base64Encode(byteData.buffer.asUint8List());

      final auth = context.read<AuthService>();
      // Гарын үсгийн зургийг sign төрлөөр илгээнэ
      await auth.uploadKycDocument(type: 'sign', image: base64Image);
      // Гэрээг зөвшөөрсөн төлөвт оруулна
      final message = await auth.acceptKycAgreement();

      if (!mounted) return;
      CustomSnackbar.show(context, message: message);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      CustomSnackbar.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return PopScope(
      // Дунд алхмуудад system back нь өмнөх алхам руу буцна
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: extendedColors.bgBase,
        appBar: AuthStepAppBar(stepText: '$_step/3', onBack: _onBack),
        body: SafeArea(
          child: _step == 3
              ? _buildSignStep(theme, l10n, extendedColors)
              : _buildContractStep(theme, l10n, extendedColors),
        ),
      ),
    );
  }

  // ─── Алхам 1, 2: гэрээ зөвшөөрөх ───

  Widget _buildContractStep(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    if (_contracts.length < 2) {
      return const Center(child: CircularProgressIndicator());
    }
    final contract = _contracts[_step - 1];

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              contract.title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
          ),
          if (contract.intro.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                contract.intro,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral200,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          for (var i = 0; i < contract.sections.length; i++) ...[
            if (i > 0) Divider(height: 1, color: extendedColors.neutral500),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContractSectionScreen(
                    number: i + 1,
                    section: contract.sections[i],
                  ),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${i + 1}. ${contract.sections[i].title}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: extendedColors.neutral300,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ],
          Divider(height: 1, color: extendedColors.neutral500),
          const SizedBox(height: 24),
          // Зөвшөөрлийн checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _agreed = !_agreed),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: extendedColors.neutral500),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _agreed
                            ? extendedColors.primaryMain
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _agreed
                              ? extendedColors.primaryMain
                              : extendedColors.neutral400,
                          width: 1.5,
                        ),
                      ),
                      child: _agreed
                          ? const Icon(Icons.check,
                              size: 18, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.acceptTerms,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: l10n.agree,
                onPressed: _agreed ? _onAgree : null,
                variant: CustomButtonVariant.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Алхам 3: гарын үсэг ───

  Widget _buildSignStep(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            l10n.signTitle,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.signSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 24),
          // Гарын үсгийн талбар
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: extendedColors.neutral500),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: RepaintBoundary(
              key: _signBoundaryKey,
              child: GestureDetector(
                onPanStart: (d) => setState(() {
                  _strokes.add([d.localPosition]);
                }),
                onPanUpdate: (d) => setState(() {
                  _strokes.last.add(d.localPosition);
                }),
                child: CustomPaint(
                  painter: _SignaturePainter(_strokes),
                  child: _strokes.isEmpty
                      ? Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 120),
                                child: Text(
                                  l10n.signHere,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                    color: extendedColors.neutral400,
                                  ),
                                ),
                              ),
                            ),
                            // Зурах шугам
                            Positioned(
                              left: 60,
                              right: 60,
                              bottom: 100,
                              child: Container(
                                height: 1,
                                color: extendedColors.neutral500,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Дахин зурах
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _strokes.clear()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: extendedColors.primary100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  l10n.redraw,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.primaryMain,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: l10n.continueLabel,
              isLoading: _isSubmitting,
              onPressed:
                  _strokes.isNotEmpty && !_isSubmitting ? _submitSignature : null,
              variant: CustomButtonVariant.primary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Гарын үсгийн зурлагыг зурна
class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    // Цагаан дэвсгэр — PNG болгоход фон нь цагаан гарна
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) {
        if (stroke.isNotEmpty) {
          canvas.drawPoints(ui.PointMode.points, stroke, paint);
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
