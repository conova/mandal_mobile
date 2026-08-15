import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';

/// Бичиг баримт (тодорхойлолт/гэрээ) авах хүсэлтийн wizard.
///
/// Route args: { doc: 'definition' | 'agreement' }
///   • definition — 2 алхам: (1) хэл + зориулалт, (2) авах төрөл
///   • agreement — шууд "авах төрөл" алхам
class DocumentRequestScreen extends StatefulWidget {
  const DocumentRequestScreen({super.key});

  @override
  State<DocumentRequestScreen> createState() => _DocumentRequestScreenState();
}

class _DocumentRequestScreenState extends State<DocumentRequestScreen> {
  int _step = 1;
  String? _lang;
  final TextEditingController _purposeController = TextEditingController();
  bool _initialized = false;
  String _doc = 'definition';

  bool get _isDefinition => _doc == 'definition';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    _doc = args['doc']?.toString() ?? 'definition';
    // Гэрээнд хэл/зориулалтын алхам байхгүй — шууд авах төрөл рүү
    if (!_isDefinition) _step = 2;
    _purposeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  /// И-мэйлийг "U********r@gmail.com" хэлбэрээр далдална
  String get _maskedEmail {
    final email =
        context.read<AuthService>().userInfo?['email']?.toString() ?? '';
    final at = email.indexOf('@');
    if (at <= 1) return email;
    final local = email.substring(0, at);
    final domain = email.substring(at);
    if (local.length <= 2) return '${local[0]}***$domain';
    return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}'
        '$domain';
  }

  void _onBack() {
    if (_step == 2 && _isDefinition) {
      setState(() => _step = 1);
    } else {
      Navigator.pop(context);
    }
  }

  /// Шууд татах — баримтыг webview-ээр харуулж хадгалах дэлгэц рүү
  void _onDirectDownload() {
    Navigator.pushNamed(
      context,
      '/securities_definition',
      arguments: {
        'doc': _doc,
        'lang': _lang ?? 'mn',
        'purpose': _purposeController.text.trim(),
      },
    );
  }

  void _onEmail() {
    // TODO: и-мэйлээр илгээх API бэлэн болмогц холбоно (4 оронтой код)
    CustomSnackbar.show(
      context,
      message: 'И-мэйлээр илгээх боломж удахгүй нэмэгдэнэ',
      type: CustomSnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final totalSteps = _isDefinition ? 2 : 1;
    final currentStep = _isDefinition ? _step : 1;

    return PopScope(
      // Step 2 (тодорхойлолт) дээр system back нь step 1 рүү буцна
      canPop: !(_step == 2 && _isDefinition),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: extendedColors.bgBase,
        appBar: AuthStepAppBar(
          stepText: '$currentStep/$totalSteps',
          onBack: _onBack,
        ),
        body: SafeArea(
          child: _step == 1
              ? _buildStep1(theme, l10n, extendedColors)
              : _buildStep2(theme, l10n, extendedColors),
        ),
      ),
    );
  }

  // ─── Алхам 1: хэл + зориулалт ───

  Widget _buildStep1(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    final canContinue =
        _lang != null && _purposeController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.securitiesStatement,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.definitionRequestSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildLangCard(
                theme,
                extendedColors,
                lang: 'mn',
                icon: 'mongolian-flag',
                label: l10n.langMongolian,
              ),
              const SizedBox(width: 12),
              _buildLangCard(
                theme,
                extendedColors,
                lang: 'en',
                icon: 'english-flag',
                label: l10n.langEnglish,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: l10n.purposeLabel,
            hint: '',
            controller: _purposeController,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.purposeExample,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral300,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: l10n.getDefinition,
              onPressed:
                  canContinue ? () => setState(() => _step = 2) : null,
              variant: CustomButtonVariant.primary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLangCard(
    ThemeData theme,
    ExtendedColors extendedColors, {
    required String lang,
    required String icon,
    required String label,
  }) {
    final isSelected = _lang == lang;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _lang = lang),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? extendedColors.primaryMain
                  : extendedColors.neutral500,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CustomSvgIcon(icon, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: extendedColors.neutral100,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Алхам 2: авах төрөл ───

  Widget _buildStep2(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            _isDefinition
                ? l10n.definitionReceiveType
                : l10n.agreementReceiveType,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.receiveTypeSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionCard(
            theme,
            extendedColors,
            icon: 'file-check-02',
            label: l10n.directDownload,
            value: l10n.downloadAsPdfLabel,
            onTap: _onDirectDownload,
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            theme,
            extendedColors,
            icon: 'email',
            label: l10n.email,
            value: _maskedEmail,
            onTap: _onEmail,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    ThemeData theme,
    ExtendedColors extendedColors, {
    required String icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: extendedColors.neutral500),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: CustomSvgIcon(
                  icon,
                  size: 26,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CustomSvgIcon(
              'chevron-right',
              size: 24,
              color: extendedColors.neutral300,
            ),
          ],
        ),
      ),
    );
  }
}
