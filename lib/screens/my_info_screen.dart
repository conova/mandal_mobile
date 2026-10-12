import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../common/validators.dart';
import '../l10n/app_localizations.dart';
import '../models/sub_account.dart';
import '../services/auth_service.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

import 'components/my_info/info_card.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Дэлгэц нээгдэхэд background-д шинэчилнэ.
    // Хэрэв cache байхгүй бол build()-д loader харагдана; мэдээлэл ирэхэд
    // notifyListeners()-р дамжаад автомат шинэчлэгдэнэ.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Хүүхдийн мэдээлэл харж байгаа бол info endpoint дуудахгүй
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args?['child'] != null) return;
      context.read<AuthService>().refreshUserInfo();
    });
  }

  String? _formatName(String? name) {
    if (name == null || name.isEmpty) return name;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.split('-').map((part) {
      if (part.isEmpty) return part;
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join('-');
  }

  /// И-мэйл нэмэх/засах dialog.
  Future<void> _showEmailDialog(String? currentEmail) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _EmailDialogContent(
          currentEmail: currentEmail,
          l10n: l10n,
          parentContext: context,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    // Хүүхдийн данс args-аар ирсэн бол түүний мэдээллийг харуулна
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final child = args?['child'] as SubAccount?;

    // Cache-аас шууд авах. Хоосон бол loader харагдана.
    final userInfo = context.watch<AuthService>().userInfo;
    final isLoading = child == null && userInfo == null;

    // Харуулах утгууд — хүүхэд бол subAcnts-ийн, үгүй бол өөрийн мэдээлэл
    final lastName = _formatName(child?.lastName ?? userInfo?['lastName']?.toString());
    final firstName = _formatName(child?.firstName ?? userInfo?['firstName']?.toString());
    final regNo = child?.register ?? userInfo?['registerNumber']?.toString();
    final email = child?.email.toLowerCase() ?? userInfo?['email']?.toString().toLowerCase();
    final phone = child?.phone ?? userInfo?['phone']?.toString();
    final address = child?.address ?? userInfo?['address']?.toString();

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
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
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            // Хүүхдийн мэдээлэл үзэж байгаа бол "Миний" гэхгүй
            child != null ? l10n.information : l10n.myInfo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            InfoCard(
              label: l10n.surname,
              value: lastName ?? '-',
            ),
            InfoCard(
              label: l10n.firstName,
              value: firstName ?? '-',
            ),
            InfoCard(
              label: l10n.regNo,
              value: regNo ?? '-',
            ),
            InfoCard(
              label: l10n.email,
              value: email ?? '-',
              // Хүүхдийн мэдээлэл зөвхөн харах горимтой — засварлахгүй
              onTap: child == null ? () => _showEmailDialog(email) : null,
              trailing: child != null
                  ? null
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userInfo?['emailVerified'] == false)
                    const CustomSvgIcon(
                      'info-circle',
                      size: 20,
                      color: AppColors.yellowMain,
                    ),
                  const SizedBox(width: 8),
                  const CustomSvgIcon(
                    'edit-03',
                    size: 20,
                    color: AppColors.primaryMain,
                  ),
                ],
              ),
            ),
            InfoCard(
              label: l10n.phoneNumber,
              value: phone ?? '-',
            ),
            InfoCard(
              label: l10n.address,
              value: address ?? '-',
              trailing: null,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Email input dialog separated into a StatefulWidget to manage its own lifecycle safely.
class _EmailDialogContent extends StatefulWidget {
  final String? currentEmail;
  final AppLocalizations l10n;
  final BuildContext parentContext;

  const _EmailDialogContent({
    required this.currentEmail,
    required this.l10n,
    required this.parentContext,
  });

  @override
  State<_EmailDialogContent> createState() => _EmailDialogContentState();
}

class _EmailDialogContentState extends State<_EmailDialogContent> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentEmail ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final message = await widget.parentContext
          .read<AuthService>()
          .addEmail(_controller.text.trim());

      if (!mounted) return;
      Navigator.pop(context, true);

      if (widget.parentContext.mounted) {
        CustomSnackbar.show(widget.parentContext, message: message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInput(
              label: widget.l10n.email,
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => Validators.validateEmail(v, widget.l10n),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: widget.l10n.save,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}