import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/dan_service.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_snackbar.dart';
import '../webview_screen.dart';

/// Хүүхдийн данс нээх — 1-р алхам: хүүхдийн регистрийн дугаар оруулах.
class ChildAccountRegisterScreen extends StatefulWidget {
  const ChildAccountRegisterScreen({super.key});

  @override
  State<ChildAccountRegisterScreen> createState() =>
      _ChildAccountRegisterScreenState();
}

class _ChildAccountRegisterScreenState
    extends State<ChildAccountRegisterScreen> {
  /// E-Mongolia-гийн CHILD_INFO-д шаардагдах иргэний бүртгэлийн дугаар
  final TextEditingController _registeredNumController =
      TextEditingController();

  /// E-Mongolia хүсэлт явуулж байгаа эсэх
  bool _isVerifying = false;

  @override
  void dispose() {
    _registeredNumController.dispose();
    super.dispose();
  }

  /// Иргэний бүртгэлийн дугаарыг E-Mongolia-гаар баталгаажуулна —
  /// DAN-тай ижил урсгал, зөвхөн CHILD_INFO service код-оор.
  Future<void> _verifyWithEMongolia() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    final l10n = AppLocalizations.of(context)!;
    try {
      final dan = context.read<DanService>();
      final auth = context.read<AuthService>();

      // CHILD_INFO — иргэний бүртгэлийн дугаарыг талбараас, регистрийн
      // дугаарыг харилцагчийн мэдээллээс авна
      final info = auth.userInfo;
      final result = await dan.startEMongolia(
        unique: auth.uid ?? '',
        callback: ApiConfig.danStatusCallback,
        services: [
          DanServiceRequest(
            'CHILD_INFO',
            params: {
              'registeredNum': _registeredNumController.text.trim(),
              'regnum':
                  (info?['registerNum'] ?? info?['registerNumber'])
                          ?.toString() ??
                      '',
            },
          ),
        ],
      );

      if (!mounted) return;

      final returned = await Navigator.pushNamed(
        context,
        '/webview',
        arguments: {
          'url': result.uri,
          'title': 'E-Mongolia',
          'callbackPrefix': ApiConfig.danStatusCallback,
          // Үр дүнг нүүр рүү шилжихийн оронд энэ дэлгэц рүү буцаана —
          // алдаатай үед хэрэглэгч урсгалаасаа гарахгүй
          'popWithResult': true,
        },
      );

      if (!mounted) return;
      // WebView өөрөө home руу шилжсэн бол энэ дэлгэц стекээс хасагдсан
      if (returned == WebViewScreen.popResultHome) return;

      if (returned != null) {
        // Үр дүн хоёр хэлбэрээр ирж болно:
        //   • {result, message} — хуудас MandalApp сувгаар мэдэгдсэн
        //   • callback URL (string) — `result` query параметртэй
        final callbackResult = returned is Map
            ? returned['result']?.toString().toLowerCase()
            : Uri.tryParse(returned.toString())
                ?.queryParameters['result']
                ?.toLowerCase();
        if (callbackResult != null && callbackResult != 'success') {
          CustomSnackbar.show(
            context,
            message: l10n.invalidNumber,
            type: CustomSnackbarType.error,
          );
          return;
        }

        // Баталгаажсан — шууд бичиг баримтын алхам руу
        _goToDocumentStep();
      }
    } on DanException catch (e) {
      if (mounted) CustomSnackbar.showError(context, e.message);
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Back товч + алхмын заалт
              Row(
                children: [
                  const CircleBackButton(),
                  const Spacer(),
                  _StepChip(label: '1/3', extendedColors: extendedColors),
                ],
              ),
              const SizedBox(height: 32),
              // Гарчиг, агуулга — гар гарч ирэхэд багтахгүй болохоос
              // сэргийлж гүйлгэдэг талбарт байрлана
              // Гар гарч ирэхэд багтахгүй болохоос сэргийлж гүйлгэнэ
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderTexts(theme, l10n, extendedColors),
                      const SizedBox(height: 24),
                      // E-Mongolia-гаар баталгаажуулахад шаардагдана
                      CustomInput(
                        label: l10n.registeredNumber,
                        controller: _registeredNumController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      // Дугаараа хаанаас олохыг зааж өгнө
                      Text(
                        l10n.registeredNumberHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w200,
                          color: extendedColors.neutral300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // E-Mongolia-гаар баталгаажуулж, амжилттай бол 2-р алхам руу
              CustomButton(
                label: l10n.register,
                isLoading: _isVerifying,
                onPressed: _canContinue ? _verifyWithEMongolia : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Дэлгэцийн гарчиг, тайлбар — хоёр салбар хуваалцана
  Widget _buildHeaderTexts(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.childRegisterTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.childRegisterDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w200,
            color: extendedColors.neutral200,
          ),
        ),
      ],
    );
  }

  /// Иргэний бүртгэлийн дугаар бичигдсэн байх ёстой
  bool get _canContinue =>
      !_isVerifying && _registeredNumController.text.trim().isNotEmpty;

  /// 2-р алхам руу — баталгаажсан иргэний бүртгэлийн дугаартайгаа
  void _goToDocumentStep() {
    Navigator.pushNamed(
      context,
      '/child_account_document',
      // Бичиг баримт илгээхэд civilId болж явна
      arguments: {'registeredNum': _registeredNumController.text.trim()},
    );
  }
}

/// Баруун дээд булангийн алхмын товч (1/3)
class _StepChip extends StatelessWidget {
  final String label;
  final ExtendedColors extendedColors;
  const _StepChip({required this.label, required this.extendedColors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: extendedColors.neutral100,
        ),
      ),
    );
  }
}
