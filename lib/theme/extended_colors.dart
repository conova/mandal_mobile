import 'package:flutter/material.dart';

@immutable
class ExtendedColors extends ThemeExtension<ExtendedColors> {
  // Primary
  final Color primaryMain;
  final Color primary500;
  final Color primary400;
  final Color primary300;
  final Color primary200;
  final Color primary100;
  final Color footerColor;

  // Neutral
  final Color neutral100;
  final Color neutral200;
  final Color neutral300;
  final Color neutral400;
  final Color neutral500;

  // Background
  final Color bgBase;
  final Color bgSecondary;
  final Color bgTertiary;

  // Functional
  final Color purple;
  final Color purple500;
  final Color purple400;
  final Color purple300;
  final Color purple200;
  final Color purple100;
  final Color orange;
  final Color orange500;
  final Color orange400;
  final Color orange300;
  final Color orange200;
  final Color orange100;
  final Color yellow;
  final Color yellow500;
  final Color yellow400;
  final Color yellow300;
  final Color yellow200;
  final Color yellow100;
  final Color red;
  final Color red500;
  final Color red400;
  final Color red300;
  final Color red200;
  final Color red100;

  // Material
  final Color material;

  const ExtendedColors({
    required this.primaryMain,
    required this.primary500,
    required this.primary400,
    required this.primary300,
    required this.primary200,
    required this.primary100,
    required this.footerColor,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral400,
    required this.neutral500,
    required this.bgBase,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.purple,
    required this.purple500,
    required this.purple400,
    required this.purple300,
    required this.purple200,
    required this.purple100,
    required this.orange,
    required this.orange500,
    required this.orange400,
    required this.orange300,
    required this.orange200,
    required this.orange100,
    required this.yellow,
    required this.yellow500,
    required this.yellow400,
    required this.yellow300,
    required this.yellow200,
    required this.yellow100,
    required this.red,
    required this.red500,
    required this.red400,
    required this.red300,
    required this.red200,
    required this.red100,
    required this.material,
  });

  @override
  ExtendedColors copyWith({
    Color? primaryMain,
    Color? primary500,
    Color? primary400,
    Color? primary300,
    Color? primary200,
    Color? primary100,
    Color? footerColor,
    Color? neutral100,
    Color? neutral200,
    Color? neutral300,
    Color? neutral400,
    Color? neutral500,
    Color? bgBase,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? purple,
    Color? purple500,
    Color? purple400,
    Color? purple300,
    Color? purple200,
    Color? purple100,
    Color? orange,
    Color? orange500,
    Color? orange400,
    Color? orange300,
    Color? orange200,
    Color? orange100,
    Color? yellow,
    Color? yellow500,
    Color? yellow400,
    Color? yellow300,
    Color? yellow200,
    Color? yellow100,
    Color? red,
    Color? red500,
    Color? red400,
    Color? red300,
    Color? red200,
    Color? red100,
    Color? material,
  }) {
    return ExtendedColors(
      primaryMain: primaryMain ?? this.primaryMain,
      primary500: primary500 ?? this.primary500,
      primary400: primary400 ?? this.primary400,
      primary300: primary300 ?? this.primary300,
      primary200: primary200 ?? this.primary200,
      primary100: primary100 ?? this.primary100,
      footerColor: footerColor ?? this.footerColor,
      neutral100: neutral100 ?? this.neutral100,
      neutral200: neutral200 ?? this.neutral200,
      neutral300: neutral300 ?? this.neutral300,
      neutral400: neutral400 ?? this.neutral400,
      neutral500: neutral500 ?? this.neutral500,
      bgBase: bgBase ?? this.bgBase,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      purple: purple ?? this.purple,
      purple500: purple500 ?? this.purple500,
      purple400: purple400 ?? this.purple400,
      purple300: purple300 ?? this.purple300,
      purple200: purple200 ?? this.purple200,
      purple100: purple100 ?? this.purple100,
      orange: orange ?? this.orange,
      orange500: orange500 ?? this.orange500,
      orange400: orange400 ?? this.orange400,
      orange300: orange300 ?? this.orange300,
      orange200: orange200 ?? this.orange200,
      orange100: orange100 ?? this.orange100,
      yellow: yellow ?? this.yellow,
      yellow500: yellow500 ?? this.yellow500,
      yellow400: yellow400 ?? this.yellow400,
      yellow300: yellow300 ?? this.yellow300,
      yellow200: yellow200 ?? this.yellow200,
      yellow100: yellow100 ?? this.yellow100,
      red: red ?? this.red,
      red500: red500 ?? this.red500,
      red400: red400 ?? this.red400,
      red300: red300 ?? this.red300,
      red200: red200 ?? this.red200,
      red100: red100 ?? this.red100,
      material: material ?? this.material,
    );
  }

  @override
  ExtendedColors lerp(ThemeExtension<ExtendedColors>? other, double t) {
    if (other is! ExtendedColors) {
      return this;
    }
    return ExtendedColors(
      primaryMain: Color.lerp(primaryMain, other.primaryMain, t)!,
      primary500: Color.lerp(primary500, other.primary500, t)!,
      primary400: Color.lerp(primary400, other.primary400, t)!,
      primary300: Color.lerp(primary300, other.primary300, t)!,
      primary200: Color.lerp(primary200, other.primary200, t)!,
      primary100: Color.lerp(primary100, other.primary100, t)!,
      footerColor: Color.lerp(footerColor, other.footerColor, t)!,
      neutral100: Color.lerp(neutral100, other.neutral100, t)!,
      neutral200: Color.lerp(neutral200, other.neutral200, t)!,
      neutral300: Color.lerp(neutral300, other.neutral300, t)!,
      neutral400: Color.lerp(neutral400, other.neutral400, t)!,
      neutral500: Color.lerp(neutral500, other.neutral500, t)!,
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgTertiary: Color.lerp(bgTertiary, other.bgTertiary, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      purple500: Color.lerp(purple500, other.purple500, t)!,
      purple400: Color.lerp(purple400, other.purple400, t)!,
      purple300: Color.lerp(purple300, other.purple300, t)!,
      purple200: Color.lerp(purple200, other.purple200, t)!,
      purple100: Color.lerp(purple100, other.purple100, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      orange500: Color.lerp(orange500, other.orange500, t)!,
      orange400: Color.lerp(orange400, other.orange400, t)!,
      orange300: Color.lerp(orange300, other.orange300, t)!,
      orange200: Color.lerp(orange200, other.orange200, t)!,
      orange100: Color.lerp(orange100, other.orange100, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      yellow500: Color.lerp(yellow500, other.yellow500, t)!,
      yellow400: Color.lerp(yellow400, other.yellow400, t)!,
      yellow300: Color.lerp(yellow300, other.yellow300, t)!,
      yellow200: Color.lerp(yellow200, other.yellow200, t)!,
      yellow100: Color.lerp(yellow100, other.yellow100, t)!,
      red: Color.lerp(red, other.red, t)!,
      red500: Color.lerp(red500, other.red500, t)!,
      red400: Color.lerp(red400, other.red400, t)!,
      red300: Color.lerp(red300, other.red300, t)!,
      red200: Color.lerp(red200, other.red200, t)!,
      red100: Color.lerp(red100, other.red100, t)!,
      material: Color.lerp(material, other.material, t)!,
    );
  }
}
