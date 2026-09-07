import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
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
import 'package:mandal_capital/theme/extended_colors.dart';

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
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  /// И-мэйл нэмэх/засах dialog. Хадгалахад /user/add_email API дуудна.
  /// Амжилттай бол AuthService кэшээ шинэчилж notifyListeners хийдэг тул
  /// энэ дэлгэцийн утга автоматаар шинэчлэгдэнэ.
  Future<void> _showEmailDialog(String? currentEmail) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentEmail ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> handleSave() async {
              if (isSaving) return;
              if (!(formKey.currentState?.validate() ?? false)) return;
              setDialogState(() => isSaving = true);
              try {
                final message = await context
                    .read<AuthService>()
                    .addEmail(controller.text.trim());
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext, true);
                if (mounted) {
                  CustomSnackbar.show(context, message: message);
                }
              } catch (e) {
                if (!dialogContext.mounted) return;
                setDialogState(() => isSaving = false);
                CustomSnackbar.show(
                  dialogContext,
                  message: e.toString().replaceFirst('Exception: ', ''),
                  type: CustomSnackbarType.error,
                );
              }
            }

            // Minimal popup — гарчиг, буцах товчгүй: зөвхөн талбар +
            // хадгалах. Гадна талд дарж хаана.
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomInput(
                      label: l10n.email,
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => Validators.validateEmail(v, l10n),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: l10n.save,
                        isLoading: isSaving,
                        onPressed: isSaving ? null : handleSave,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    controller.dispose();
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
        title: Padding(
          padding: EdgeInsets.only(top: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                                const CustomSvgIcon('info-circle', size: 20, color: AppColors.yellowMain,),
                              const SizedBox(width: 8),
                              const CustomSvgIcon('edit-03', size: 20, color: AppColors.primaryMain,),
                            ],
                          ),
                  ),
                  InfoCard(
                    label: l10n.phoneNumber,
                    value: phone ?? '-',
                    trailing: child != null
                        ? null
                        : const CustomSvgIcon('edit-03', size: 20, color: AppColors.primaryMain,),
                  ),
                  InfoCard(
                    label: l10n.address,
                    value: address ?? '-',
                    trailing: child != null
                        ? null
                        : null///const CustomSvgIcon('edit-03', size: 20, color: AppColors.primaryMain,),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
          ),
    );
  }
}
