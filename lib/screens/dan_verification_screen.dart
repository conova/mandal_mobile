import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/dan_service.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/circle_back_button.dart';
import 'webview_screen.dart';

class DanVerificationScreen extends StatefulWidget {
  const DanVerificationScreen({super.key});

  @override
  State<DanVerificationScreen> createState() => _DanVerificationScreenState();
}

class _DanVerificationScreenState extends State<DanVerificationScreen> {
  bool _isLoading = false;
  bool _isApproved = false;

  Future<void> _handleVerify() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dan = context.read<DanService>();
      final auth = context.read<AuthService>();

      // unique — энэ хэрэглэгчийн identifier (uid). Backend session-аа
      // үүсгэх ба бид webview хаагдсаны дараа `isDanVerified` flag-ийг
      // дахин unfo татаж шинэчилнэ.
      final unique = auth.uid ?? '';
      // callback — DAN gateway хэрэглэгчийг redirect хийх URL.
      const callback = 'https://bds.techfi.mn/bdc/api/kyc/dan_status';

      final result = await dan.startEMongolia(
        unique: unique,
        callback: callback,
        serviceCodes: const [
          'CITIZEN_ID_CARD_INFO',
          'CITIZEN_ADDRESS_INFO',
        ],
      );

      if (!mounted) return;

      // WebView нээх, callback URL руу redirect болоход pop хийнэ.
      // `homeRoute` дамжуулж, e-Mongolia хуудас доторх JS / scheme
      // (`mandalapp://home` эсвэл `MandalApp.postMessage('navigate_home')`)
      // ажиллахад шууд home tab руу шилжих боломжтой.
      final returned = await Navigator.pushNamed(
        context,
        '/webview',
        arguments: {
          'url': result.uri,
          'title': 'E-Mongolia',
          'callbackPrefix': callback,
          // '/main' (bottom nav-тай контейнер) руу буулгана — нүцгэн '/home'
          // руу буувал доод цэсгүй, back дарахад аппаас гарна
          'homeRoute': '/main',
        },
      );

      if (!mounted) return;

      // WebView дотроос "home руу шилжих" action ажилласан тохиолдолд
      // WebView нь өөрөө pushNamedAndRemoveUntil('/home') хийсэн ба
      // энэ дэлгэц ч мөн стекээс хасагдсан байгаа болохоор юу ч хийхгүй.
      if (returned == WebViewScreen.popResultHome) {
        return;
      }

      if (returned != null) {
        // User мэдээллийг шинэчилж DAN flag-ийг дахин шалгана
        try {
          await auth.refreshUserInfo();
        } catch (_) {
          // info татах амжилтгүй ч UI-аа approved болгоё
        }
        setState(() {
          _isLoading = false;
          _isApproved = true;
        });
      } else {
        // Хэрэглэгч цуцалсан
        setState(() => _isLoading = false);
      }
    } on DanException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _handleNext() {
    Navigator.pushNamed(context, '/securities_agreement');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: _DanAppBar(theme: theme, extendedColors: extendedColors),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: _DanHeaderIcon(
                extendedColors: extendedColors,
                isApproved: _isApproved,
              ),
            ),
            const SizedBox(height: 32),
            _DanContent(l10n: l10n, theme: theme, isApproved: _isApproved, extendedColors: extendedColors),
            const SizedBox(height: 64),
            _DanActionButtons(
              l10n: l10n,
              isLoading: _isLoading,
              isApproved: _isApproved,
              onVerify: _handleVerify,
              onNext: _handleNext,
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class _DanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _DanAppBar({required this.theme, required this.extendedColors});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircleBackButton(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _DanHeaderIcon extends StatelessWidget {
  final ExtendedColors extendedColors;
  final bool isApproved;

  const _DanHeaderIcon({
    required this.extendedColors,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: isApproved
          ? Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: extendedColors.primaryMain,
            )
          : Image.asset('assets/images/finger_print.png', fit: BoxFit.contain),
    );
  }
}

class _DanContent extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isApproved;
  final ExtendedColors extendedColors;

  const _DanContent({
    required this.l10n,
    required this.theme,
    required this.isApproved,
    required this.extendedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isApproved ? 'Систем баталгаажлаа' : l10n.danSystem,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: extendedColors.neutral100,
              fontWeight: AppTextStyles.semiBold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isApproved
                ? 'Таны мэдээлэл системд амжилттай баталгаажлаа.'
                : l10n.danVerificationDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }
}

class _DanActionButtons extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isLoading;
  final bool isApproved;
  final VoidCallback onVerify;
  final VoidCallback onNext;

  const _DanActionButtons({
    required this.l10n,
    required this.isLoading,
    required this.isApproved,
    required this.onVerify,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: isApproved ? 'Дараах' : l10n.verify,
            isLoading: isLoading,
            onPressed: isApproved ? onNext : onVerify,
            variant: CustomButtonVariant.primary,
          ),
        ),
      ],
    );
  }
}
