import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// assets/images/icons/ доторх SVG icon-ыг зөвхөн нэрээр нь дуудаж харуулна:
///
/// ```dart
/// CustomSvgIcon('wallet-01')                    // 24x24, IconTheme өнгөөр
/// CustomSvgIcon('wallet-01', size: 32)
/// CustomSvgIcon('wallet-01', color: extendedColors.primaryMain)
/// ```
///
/// Өнгө заагаагүй бол [IconTheme]-ийн өнгөөр tint хийдэг тул
/// BottomNavigationBar, IconButton, ListTile г.м. дотор Material [Icon]-той
/// яг ижил (сонгогдсон/идэвхгүй, dark/light) ажиллана. SVG доторх хатуу
/// stroke/fill өнгийг үл харгалзан бүтэн tint хийнэ.
class CustomSvgIcon extends StatelessWidget {
  /// Icon-ы нэр — assets/images/icons/`name`.svg ('.svg'-гүй бичнэ)
  final String name;
  final double size;

  /// Заагаагүй бол IconTheme-ийн өнгө; tint хийхгүй байх бол
  /// [preserveColors]-ийг true болгоно
  final Color? color;

  /// true бол SVG-ийн өөрийнх нь өнгийг хэвээр харуулна (олон өнгөт icon)
  final bool preserveColors;

  const CustomSvgIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color,
    this.preserveColors = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      'assets/images/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: (preserveColors || effectiveColor == null)
          ? null
          : ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
