import 'package:flutter/material.dart';

import '../../../theme/extended_colors.dart';
import '../../../widgets/circle_back_button.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String phoneNumber;

  /// Харилцагчийн зургийн URL (/user/info-ийн `photo`).
  /// null эсвэл хоосон бол одоогийн байдлаар person icon харуулна.
  final String? photoUrl;

  /// Өгвөл зураг/person icon-ий оронд энэ widget-ийг харуулна
  /// (жишээ нь хүүхдийн үсэгтэй InitialAvatar)
  final Widget? avatar;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.phoneNumber,
    this.photoUrl,
    this.avatar,
  });

  void _showFullImage(BuildContext context, ExtendedColors extendedColors) {
    if (photoUrl == null || photoUrl!.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: extendedColors.bgBase,
          appBar: AppBar(
            backgroundColor: extendedColors.bgBase,
            elevation: 0,
            // M3 default-аар scroll болоход AppBar нь surfaceTint өнгөөр өнгөрсөн
            // tint авдаг — энэ нь bgBase-тай ялгаатай харагдана. Бид tint-ийг
            // унтрааж, scrolledUnderElevation-ыг 0 болгож scroll-ын явцад
            // background bgBase-аараа үлдэхийг баталгаажуулна.
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            toolbarHeight: 70,
            leadingWidth: 60,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
            ),
          ),
          body: Center(
            child: Hero(
              tag: 'profile_avatar_hero',
              child: InteractiveViewer(
                child: Image.network(
                  photoUrl!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final fallbackIcon = Icon(
      Icons.person,
      size: 80,
      color: extendedColors.bgTertiary,
    );

    final bool hasImage = photoUrl != null && photoUrl!.isNotEmpty;

    return Center(
      child: Column(
        children: [
          if (avatar != null)
            avatar!
          else
            GestureDetector(
              onTap: hasImage ? () => _showFullImage(context, extendedColors) : null,
              child: Hero(
                tag: 'profile_avatar_hero',
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: extendedColors.bgSecondary,
                  child: hasImage
                      ? ClipOval(
                          child: Image.network(
                            photoUrl!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            // Зураг татагдтал болон алдаа гарвал icon-оо харуулна
                            errorBuilder: (_, _, _) => fallbackIcon,
                            loadingBuilder: (context, child, progress) =>
                                progress == null ? child : fallbackIcon,
                          ),
                        )
                      : fallbackIcon,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phoneNumber,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
