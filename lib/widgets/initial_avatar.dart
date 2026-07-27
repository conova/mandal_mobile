import 'package:flutter/material.dart';

/// Нэрний эхний үсэгтэй дөрвөлжин аватар — profile switcher,
/// хүүхдийн профайл зэрэгт хэрэглэгдэнэ.
class InitialAvatar extends StatelessWidget {
  final String initial;
  final Color color;
  final double size;

  const InitialAvatar({
    super.key,
    required this.initial,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Center(
        child: Text(
          initial,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            // Аватарын хэмжээг дагаж үсэг томорно
            fontSize: size * 0.42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
