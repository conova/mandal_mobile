import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../common/validators.dart';
import '../l10n/app_localizations.dart';
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
      context.read<AuthService>().refreshUserInfo();
    });
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

    // Cache-аас шууд авах. Хоосон бол loader харагдана.
    final userInfo = context.watch<AuthService>().userInfo;
    final isLoading = userInfo == null;

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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Text(
                    l10n.myInfo,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),
                  InfoCard(
                    label: l10n.surname,
                    value: userInfo['lastName']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.firstName,
                    value: userInfo['firstName']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.regNo,
                    value: userInfo['registerNumber']?.toString() ?? '-',
                  ),
                  InfoCard(
                    label: l10n.email,
                    value: userInfo['email']?.toString() ?? '-',
                    onTap: () =>
                        _showEmailDialog(userInfo['email']?.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (userInfo['emailVerified'] == false)
                          const CustomSvgIcon('info-circle', size: 20, color: AppColors.yellowMain,),
                        const SizedBox(width: 8),
                        const CustomSvgIcon('edit-03', size: 20, color: AppColors.primaryMain,),
                      ],
                    ),
                  ),
                  InfoCard(
                    label: l10n.phoneNumber,
                    value: userInfo['phone']?.toString() ?? '-',
                    trailing: const CustomSvgIcon('edit-03', size: 20, color: AppColors.primaryMain,),
                  ),
                  InfoCard(
                    label: l10n.address,
                    value: userInfo['address']?.toString() ?? '-',
                    trailing: const CustomSvgIcon('edit-03', size: 20, color: AppColors.primaryMain,),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
          ),
    );
  }
}
