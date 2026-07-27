import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_snackbar.dart';

/// Хүүхдийн данс нээх — 2-р алхам: төрсний гэрчилгээний зураг оруулах.
///
/// Route args: `{'register': String}` (1-р алхмаас)
class ChildAccountDocumentScreen extends StatefulWidget {
  const ChildAccountDocumentScreen({super.key});

  @override
  State<ChildAccountDocumentScreen> createState() =>
      _ChildAccountDocumentScreenState();
}

class _ChildAccountDocumentScreenState
    extends State<ChildAccountDocumentScreen> {
  /// Камераас буцсан зураг (path эсвэл base64) — null бол хараахан аваагүй
  Object? _photoResult;
  bool _isSending = false;

  Future<void> _takePhoto() async {
    final result = await Navigator.pushNamed(
      context,
      '/camera_overlay',
      arguments: {
        'type': 'id',
        // Header дээр "Төрсний гэрчилгээ" гэж гарна
        'title': AppLocalizations.of(context)!.birthCertificate,
      },
    );
    if (result != null && mounted) {
      setState(() => _photoResult = result);
    }
  }

  Future<void> _send() async {
    if (_photoResult == null || _isSending) return;
    setState(() => _isSending = true);
    try {
      // TODO: Хүүхдийн бүртгэлийн API холбогдох үед энд илгээнэ
      // (register: args-аас, зураг: _photoResult)
      if (!mounted) return;
      Navigator.pushNamed(context, '/child_account_success');
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final hasPhoto = _photoResult != null;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircleBackButton(),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: extendedColors.bgSecondary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '2/3',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                l10n.childDocTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
              const SizedBox(height: 24),
              // Зураг оруулах мөр
              InkWell(
                onTap: _takePhoto,
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CustomSvgIcon('camera-plus'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.birthCertificate,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: extendedColors.neutral100,
                            ),
                          ),
                          Text(
                            hasPhoto ? l10n.success : l10n.addPhoto,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: hasPhoto
                                  ? extendedColors.primaryMain
                                  : extendedColors.neutral300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: extendedColors.neutral300,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Зургийн шаардлага
              Text(
                l10n.photoRequirements,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
              const SizedBox(height: 16),
              for (final req in [
                l10n.reqCorner,
                l10n.reqValid,
                l10n.reqClear,
                l10n.reqReadable,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        size: 20,
                        color: extendedColors.primaryMain,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          req,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: extendedColors.neutral100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Divider(height: 1, color: extendedColors.neutral500),
              const SizedBox(height: 16),
              CustomButton(
                label: l10n.sendPhoto,
                isLoading: _isSending,
                onPressed: hasPhoto ? _send : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
