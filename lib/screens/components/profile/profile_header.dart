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

    double dragY = 0;
    bool dragging = false;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: extendedColors.bgBase,
          extendBodyBehindAppBar: true, // image slides under the back button
          appBar: AppBar(
            backgroundColor: extendedColors.bgBase,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            toolbarHeight: 70,
            leadingWidth: 60,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
            ),
          ),
          body: StatefulBuilder(
            builder: (context, setState) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => setState(() => dragging = true),
              onVerticalDragUpdate: (d) => setState(() {
                // Only upward movement is allowed (negative values)
                dragY = (dragY + d.delta.dy).clamp(-1000.0, 0.0).toDouble();
              }),
              onVerticalDragEnd: (d) {
                if (dragY < -120 || (d.primaryVelocity ?? 0) < -700) {
                  Navigator.of(context).maybePop(); // Hero animates back
                } else {
                  setState(() {
                    dragging = false;
                    dragY = 0; // snap back
                  });
                }
              },
              child: AnimatedContainer(
                duration:
                dragging ? Duration.zero : const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, dragY, 0),
                child: Center(
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
