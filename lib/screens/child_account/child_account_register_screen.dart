import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/validators.dart';
import '../../config/api_config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/child_info.dart';
import '../../services/auth_service.dart';
import '../../services/dan_service.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/initial_avatar.dart';
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
  final TextEditingController _registerController = TextEditingController();

  /// E-Mongolia хүсэлт үүсгэж байгаа эсэх
  bool _isFetchingChildren = false;

  /// E-Mongolia-аас татагдаж сервер дээр хадгалагдсан хүүхдүүд.
  /// Хоосон биш бол регистр гараар бичихийн оронд жагсаалтаас сонгоно.
  List<ChildInfo> _children = const [];
  int? _selectedChildId;

  ChildInfo? get _selectedChild {
    final id = _selectedChildId;
    if (id == null) return null;
    for (final c in _children) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  void dispose() {
    _registerController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _registerController.text.trim().isNotEmpty;

  /// E-Mongolia-аас хүүхдийн жагсаалт татах — DAN баталгаажуулалттай ижил
  /// урсгал, зөвхөн CHILD_INFO service код-оор хүсэлт илгээнэ.
  Future<void> _fetchChildrenFromEMongolia() async {
    if (_isFetchingChildren) return;
    setState(() => _isFetchingChildren = true);

    final l10n = AppLocalizations.of(context)!;
    try {
      final dan = context.read<DanService>();
      final auth = context.read<AuthService>();

      // CHILD_INFO нь эцэг/эхийн бүртгэлийн болон регистрийн дугаарыг
      // параметрээр шаардана
      final info = auth.userInfo;
      final result = await dan.startEMongolia(
        unique: auth.uid ?? '',
        callback: ApiConfig.danStatusCallback,
        services: [
          DanServiceRequest(
            'CHILD_INFO',
            params: {
              'registeredNum': info?['civilId']?.toString() ?? '',
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
          'homeRoute': '/main',
        },
      );

      if (!mounted) return;
      // WebView өөрөө home руу шилжсэн бол энэ дэлгэц стекээс хасагдсан
      if (returned == WebViewScreen.popResultHome) return;

      if (returned != null) {
        // E-Mongolia амжилттай хариу өгсөн — серверт хадгалагдсан
        // хүүхдүүдийн жагсаалтыг татаж харуулна
        final children = await auth.getChildren();
        if (!mounted) return;
        setState(() {
          _children = children;
          // Ганц хүүхэдтэй бол шууд сонгож өгнө
          _selectedChildId = children.length == 1 ? children.first.id : null;
        });
        if (children.isEmpty) {
          CustomSnackbar.show(
            context,
            message: l10n.childListEmpty,
            type: CustomSnackbarType.info,
          );
        }
      }
    } on DanException catch (e) {
      if (mounted) CustomSnackbar.showError(context, e.message);
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isFetchingChildren = false);
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
              const SizedBox(height: 24),
              // E-Mongolia-аас хүүхэд татагдсан бол жагсаалтаас сонгоно,
              // үгүй бол регистрийг нь гараар оруулна
              if (_children.isNotEmpty)
                Expanded(child: _buildChildList(theme, l10n, extendedColors))
              else ...[
                CustomInput(
                  label: l10n.registrationNumber,
                  controller: _registerController,
                  validator: (v) =>
                      Validators.validateMongolianRegister(v, l10n),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                // Регистрээ гараар бичихийн оронд E-Mongolia-аас татах
                CustomButton(
                  size: CustomButtonSize.small,
                  label: l10n.fetchChildListEmongolia,
                  variant: CustomButtonVariant.secondary,
                  isLoading: _isFetchingChildren,
                  onPressed:
                      _isFetchingChildren ? null : _fetchChildrenFromEMongolia,
                ),
                const Spacer(),
              ],
              CustomButton(
                label: _children.isNotEmpty ? l10n.continueLabel : l10n.register,
                onPressed: _canContinue ? _goToDocumentStep : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Жагсаалттай үед хүүхэд сонгогдсон, үгүй бол регистр бичигдсэн байх ёстой
  bool get _canContinue =>
      _children.isNotEmpty ? _selectedChild != null : _isValid;

  /// 2-р алхам руу — сонгосон хүүхдийн (эсвэл гараар бичсэн) мэдээллээр
  void _goToDocumentStep() {
    final child = _selectedChild;
    Navigator.pushNamed(
      context,
      '/child_account_document',
      arguments: {
        'register': child?.registerNumber ?? _registerController.text.trim(),
        if (child != null) ...{
          'childId': child.id,
          'firstName': child.firstName,
          'lastName': child.lastName,
        },
      },
    );
  }

  /// E-Mongolia-аас татагдсан хүүхдүүд — radio-той сонгох жагсаалт
  Widget _buildChildList(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectChildLabel,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _children.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _buildChildCard(
              _children[index],
              theme,
              extendedColors,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChildCard(
    ChildInfo child,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final isSelected = _selectedChildId == child.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedChildId = child.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? extendedColors.primaryMain
                : extendedColors.neutral500,
          ),
        ),
        child: Row(
          children: [
            InitialAvatar(
              initial: child.initial,
              color: extendedColors.primaryMain,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    child.registerNumber,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? extendedColors.primaryMain
                      : extendedColors.neutral400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: extendedColors.primaryMain,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
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
