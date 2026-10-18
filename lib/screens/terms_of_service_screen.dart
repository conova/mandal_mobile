import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../common/html_content.dart';
import '../l10n/app_localizations.dart';
import '../services/content_service.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';

/// Үйлчилгээний нөхцөл — /api/mobile/contracts-ийн агуулгаас
/// `class="terms"` HTML элемент(үүд)-ийг олж харуулна
class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  String? _html;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final body = await ContentService.contracts();
      if (!mounted) return;
      setState(() {
        _html = extractHtmlByClass(body, 'terms');
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircleBackButton(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.termsOfService,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: extendedColors.primaryMain,
                      ),
                    )
                  : _html == null
                      ? Center(
                          child: Text(
                            l10n.termsNotFound,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: AppTextStyles.light,
                              color: extendedColors.neutral200,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                          child: HtmlWidget(
                            prepareHtmlContent(_html!),
                            textStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: extendedColors.neutral200,
                              height: 1.6,
                            ),
                            // Холбоосыг app доторх webview-ээр нээнэ
                            onTapUrl: (url) {
                              Navigator.pushNamed(
                                context,
                                '/webview',
                                arguments: {
                                  'url': url,
                                  'title': l10n.termsOfService,
                                },
                              );
                              return true;
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
