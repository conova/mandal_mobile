import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';

class DanVerificationScreen extends StatefulWidget {
  const DanVerificationScreen({super.key});

  @override
  State<DanVerificationScreen> createState() => _DanVerificationScreenState();
}

class _DanVerificationScreenState extends State<DanVerificationScreen> {
  bool _isLoading = false;
  bool _isApproved = false;

  void _handleVerify() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate DAN verification process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isApproved = true;
      });
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
            _DanContent(l10n: l10n, theme: theme, isApproved: _isApproved),
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
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: extendedColors.neutral500,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              size: 20,
              color: theme.colorScheme.onBackground,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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

  const _DanContent({
    required this.l10n,
    required this.theme,
    required this.isApproved,
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
              color: theme.colorScheme.onBackground,
              fontWeight: AppTextStyles.semiBold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isApproved
                ? 'Таны мэдээлэл системд амжилттай баталгаажлаа.'
                : l10n.danVerificationDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
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
