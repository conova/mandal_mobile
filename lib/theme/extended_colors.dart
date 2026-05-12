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
  final Color orange;
  final Color yellow;
  final Color red;

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
    required this.orange,
    required this.yellow,
    required this.red,
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
    Color? orange,
    Color? yellow,
    Color? red,
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
      orange: orange ?? this.orange,
      yellow: yellow ?? this.yellow,
      red: red ?? this.red,
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
      orange: Color.lerp(orange, other.orange, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      red: Color.lerp(red, other.red, t)!,
      material: Color.lerp(material, other.material, t)!,
    );
  }
}
