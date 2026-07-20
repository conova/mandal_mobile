import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  String? _idFrontPath;
  String? _idBackPath;
  String? _selfiePath;
  bool _initialized = false;
  bool _uploadingIdFront = false;
  bool _uploadingIdBack = false;
  bool _uploadingSelfie = false;

  /// Илгээлтийн явц type тус бүрээр (0.0–1.0); илгээгээгүй үед байхгүй
  final Map<String, double> _uploadProgress = {};

  bool get _isIdFrontDone => _idFrontPath != null;
  bool get _isIdBackDone => _idBackPath != null;
  bool get _isSelfieDone => _selfiePath != null;

  bool get _isAllDone => _isIdFrontDone && _isIdBackDone && _isSelfieDone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    // Өмнө нь илгээгдсэн баримтуудыг `userInfo.kycDocs`-ийн URL-аар дүүргэж
    // thumbnail-д нь харуулна. URL байхгүй ч илгээгдсэн гэж тэмдэглэгдсэн
    // бол 'done' sentinel (icon-той "хийгдсэн" төлөв) ашиглана.
    final auth = context.read<AuthService>();
    setState(() {
      if (auth.isIdFrontUploaded) {
        _idFrontPath = auth.kycDocUrl('id_front') ?? 'done';
      }
      if (auth.isIdBackUploaded) {
        _idBackPath = auth.kycDocUrl('id_back') ?? 'done';
      }
      if (auth.isSelfieUploaded) {
        _selfiePath = auth.kycDocUrl('selfie') ?? 'done';
      }
    });
  }

  /// Камераас буцаж ирсэн path-аас base64 string үүсгээд upload_document API дуудна.
  /// Web дээр File API ажиллахгүй учир алдаа барина.
  Future<void> _uploadDocument({
    required String type,
    required dynamic cameraResult,
  }) async {
    // 'done' эсвэл null → upload алгасах
    if (cameraResult is! String || cameraResult == 'done') return;

    // BuildContext-аас async-н өмнө шууд авах
    final auth = context.read<AuthService>();

    setState(() {
      if (type == 'id_front') _uploadingIdFront = true;
      if (type == 'id_back') _uploadingIdBack = true;
      if (type == 'selfie') _uploadingSelfie = true;
      _uploadProgress[type] = 0;
    });

    try {
      String base64Image;
      if (kIsWeb) {
        // Web flow: cameraResult аль хэдийн base64 байх ёстой
        base64Image = cameraResult;
      } else {
        final bytes = await File(cameraResult).readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final url = await auth.uploadKycDocument(
        type: type,
        image: base64Image,
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _uploadProgress[type] = sent / total);
        },
      );

      // Сервер хадгалсан URL-аа буцаадаг — thumbnail-ийг түүгээр солино
      // (web дээр локал path харуулж чадахгүй тул энэ нь бас чухал)
      if (url != null && url.isNotEmpty && mounted) {
        setState(() {
          if (type == 'id_front') _idFrontPath = url;
          if (type == 'id_back') _idBackPath = url;
          if (type == 'selfie') _selfiePath = url;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (type == 'id_front') _uploadingIdFront = false;
          if (type == 'id_back') _uploadingIdBack = false;
          if (type == 'selfie') _uploadingSelfie = false;
          _uploadProgress.remove(type);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: _DocAppBar(theme: theme, extendedColors: extendedColors),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _DocHeader(l10n: l10n, theme: theme, extendedColors: extendedColors),
              const SizedBox(height: 32),
              _DocItemList(
                l10n: l10n,
                isIdFrontDone: _isIdFrontDone,
                isIdBackDone: _isIdBackDone,
                isSelfieDone: _isSelfieDone,
                idFrontPath: _idFrontPath,
                idBackPath: _idBackPath,
                selfiePath: _selfiePath,
                isUploadingIdFront: _uploadingIdFront,
                isUploadingIdBack: _uploadingIdBack,
                isUploadingSelfie: _uploadingSelfie,
                idFrontProgress: _uploadProgress['id_front'],
                idBackProgress: _uploadProgress['id_back'],
                selfieProgress: _uploadProgress['selfie'],
                onIdFrontTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'id',
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _idFrontPath = result is String ? result : 'done';
                    });
                    await _uploadDocument(type: 'id_front', cameraResult: result);
                  }
                },
                onIdBackTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'id',
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _idBackPath = result is String ? result : 'done';
                    });
                    await _uploadDocument(type: 'id_back', cameraResult: result);
                  }
                },
                onSelfieTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/camera_overlay',
                    arguments: 'selfie',
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _selfiePath = result is String ? result : 'done';
                    });
                    await _uploadDocument(type: 'selfie', cameraResult: result);
                  }
                },
              ),
              const SizedBox(height: 32),
              _DocRequirements(
                l10n: l10n,
                theme: theme,
                extendedColors: extendedColors,
              ),
              const Spacer(),
              _DocActionButtons(
                l10n: l10n,
                isAllDone: _isAllDone,
                onSend: () {
                  Navigator.pushNamed(context, '/onboarding_success');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _DocAppBar({required this.theme, required this.extendedColors});

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

class _DocHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _DocHeader({required this.l10n, required this.theme, required this.extendedColors});

  @override
  Widget build(BuildContext context) {
    final extendedColors = theme.extension<ExtendedColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.document,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: extendedColors.neutral100,
            fontWeight: AppTextStyles.semiBold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.documentDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral200,
            fontWeight: AppTextStyles.light,
          ),
        ),
      ],
    );
  }
}

class _DocItemList extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isIdFrontDone;
  final bool isIdBackDone;
  final bool isSelfieDone;
  final String? idFrontPath;
  final String? idBackPath;
  final String? selfiePath;
  final bool isUploadingIdFront;
  final bool isUploadingIdBack;
  final bool isUploadingSelfie;
  final double? idFrontProgress;
  final double? idBackProgress;
  final double? selfieProgress;
  final VoidCallback onIdFrontTap;
  final VoidCallback onIdBackTap;
  final VoidCallback onSelfieTap;

  const _DocItemList({
    required this.l10n,
    required this.isIdFrontDone,
    required this.isIdBackDone,
    required this.isSelfieDone,
    this.idFrontPath,
    this.idBackPath,
    this.selfiePath,
    this.isUploadingIdFront = false,
    this.isUploadingIdBack = false,
    this.isUploadingSelfie = false,
    this.idFrontProgress,
    this.idBackProgress,
    this.selfieProgress,
    required this.onIdFrontTap,
    required this.onIdBackTap,
    required this.onSelfieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DocItem(
          title: l10n.idFront,
          isDone: isIdFrontDone,
          imagePath: idFrontPath,
          isUploading: isUploadingIdFront,
          uploadProgress: idFrontProgress,
          onTap: onIdFrontTap,
        ),
        _DocItem(
          title: l10n.idBack,
          isDone: isIdBackDone,
          imagePath: idBackPath,
          isUploading: isUploadingIdBack,
          uploadProgress: idBackProgress,
          onTap: onIdBackTap,
        ),
        _DocItem(
          title: l10n.selfiePhoto,
          isDone: isSelfieDone,
          imagePath: selfiePath,
          isUploading: isUploadingSelfie,
          uploadProgress: selfieProgress,
          onTap: onSelfieTap,
        ),
      ],
    );
  }
}

class _DocItem extends StatelessWidget {
  final String title;
  final bool isDone;
  final String? imagePath;
  final bool isUploading;

  /// Илгээлтийн явц 0.0–1.0 (null бол тодорхойгүй spinner)
  final double? uploadProgress;
  final VoidCallback onTap;

  const _DocItem({
    required this.title,
    required this.isDone,
    this.imagePath,
    this.isUploading = false,
    this.uploadProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: isUploading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: isUploading
                  ? Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          // Явц мэдэгдэж байвал бодит progress, үгүй бол
                          // тодорхойгүй spinner
                          value: uploadProgress,
                        ),
                      ),
                    )
                  : _buildThumbnail(extendedColors),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppTextStyles.light,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploading
                        ? '${l10n.uploading}... '
                            '${((uploadProgress ?? 0) * 100).round()}%'
                        : (isDone ? l10n.editPhoto : l10n.addPhoto),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppTextStyles.light,
                      color: (isUploading || isDone)
                          ? extendedColors.primaryMain
                          : extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: extendedColors.neutral400),
          ],
        ),
      ),
    );
  }

  /// Илгээгдсэн зургийн thumbnail:
  ///   • http URL (kycDocs / upload-ийн хариу) → Image.network
  ///   • локал path (камераас дөнгөж авсан, mobile) → Image.file
  ///   • 'done' sentinel эсвэл зураггүй → камерын icon
  Widget _buildThumbnail(ExtendedColors extendedColors) {
    final placeholder = Icon(
      Icons.camera_alt_outlined,
      color: extendedColors.neutral300,
    );

    final path = imagePath;
    if (!isDone || path == null || path == 'done') return placeholder;

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
      );
    }

    if (!kIsWeb) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    return placeholder;
  }
}

class _DocRequirements extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _DocRequirements({
    required this.l10n,
    required this.theme,
    required this.extendedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.photoRequirements,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: AppTextStyles.bold,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 16),
        _RequirementItem(
          text: l10n.reqCorner,
          extendedColors: extendedColors,
          theme: theme,
        ),
        _RequirementItem(
          text: l10n.reqValid,
          extendedColors: extendedColors,
          theme: theme,
        ),
        _RequirementItem(
          text: l10n.reqClear,
          extendedColors: extendedColors,
          theme: theme,
        ),
        _RequirementItem(
          text: l10n.reqReadable,
          extendedColors: extendedColors,
          theme: theme,
        ),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final ExtendedColors extendedColors;
  final ThemeData theme;

  const _RequirementItem({
    required this.text,
    required this.extendedColors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check, size: 19, color: extendedColors.primaryMain),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                color: extendedColors.neutral100,
                fontWeight: AppTextStyles.light,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocActionButtons extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isAllDone;
  final VoidCallback onSend;

  const _DocActionButtons({
    required this.l10n,
    required this.isAllDone,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: extendedColors.neutral500, width: 1.0),
        ),
      ),
      child: CustomButton(
        label: l10n.sendPhoto,
        onPressed: isAllDone ? onSend : null,
        variant: CustomButtonVariant.primary,
      ),
    );
  }
}
