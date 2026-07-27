import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final fallbackIcon = Icon(
      Icons.person,
      size: 80,
      color: colorScheme.tertiary,
    );

    return Center(
      child: Column(
        children: [
          if (avatar != null)
            avatar!
          else
          CircleAvatar(
            radius: 45,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: (photoUrl != null && photoUrl!.isNotEmpty)
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
