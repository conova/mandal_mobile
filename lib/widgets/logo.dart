import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo_mini.svg', 
      width: width,
      height: height,
      colorFilter: color != null 
          ? ColorFilter.mode(color!, BlendMode.srcIn) 
          : null,
      placeholderBuilder: (context) => const SizedBox.shrink(),
    );
  }
}
