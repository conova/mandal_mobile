import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/validators.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

import 'components/my_info/info_card.dart';
import 'components/my_info/my_info_back_button.dart';

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

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                (currentEmail == null || currentEmail.isEmpty)
                    ? l10n.addEmail
                    : l10n.email,
              ),
              content: Form(
                key: formKey,
                child: CustomInput(
                  label: l10n.email,
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => Validators.validateEmail(v, l10n),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              actions: [
                CustomButton(
                  label: l10n.back,
                  variant: CustomButtonVariant.text,
                  size: CustomButtonSize.small,
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                ),
                CustomButton(
                  label: l10n.save,
                  size: CustomButtonSize.small,
                  isLoading: isSaving,
                  onPressed: isSaving ? null : handleSave,
                ),
              ],
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
    final colorScheme = theme.colorScheme;

    // Cache-аас шууд авах. Хоосон бол loader харагдана.
    final userInfo = context.watch<AuthService>().userInfo;
    final isLoading = userInfo == null;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const MyInfoBackButton(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.myInfo,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                        if (userInfo['emailVerified'] == true)
                          Icon(
                            Icons.verified_user_outlined,
                            color: extendedColors.primaryMain,
                            size: 18,
                          )
                        else
                          Icon(
                            Icons.warning_amber_outlined,
                            color: extendedColors.orange,
                            size: 18,
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit_outlined,
                          color: extendedColors.primaryMain,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  InfoCard(
                    label: l10n.phoneNumber,
                    value: userInfo['phone']?.toString() ?? '-',
                    trailing: Icon(
                      Icons.edit_outlined,
                      color: extendedColors.primaryMain,
                      size: 18,
                    ),
                  ),
                  InfoCard(
                    label: l10n.address,
                    value: userInfo['address']?.toString() ?? '-',
                    trailing: Icon(
                      Icons.edit_outlined,
                      color: extendedColors.primaryMain,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
