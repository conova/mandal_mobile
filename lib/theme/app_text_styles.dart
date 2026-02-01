import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static const String _fontFamily = 'Geologica';

  // Weights
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight semiBold = FontWeight.w600;

  // Display
  static TextStyle display = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 34,
    height: 40 / 34,
    letterSpacing: 34 * -0.015,
    fontWeight: semiBold,
  );

  // Headlines
  static TextStyle h1 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 27,
    height: 36 / 27,
    letterSpacing: 27 * -0.004,
    fontWeight: semiBold,
  );

  static TextStyle h2 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 22,
    height: 32 / 22,
    letterSpacing: 22 * -0.002,
    fontWeight: semiBold,
  );

  static TextStyle h3 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 18,
    height: 28 / 18,
    letterSpacing: 18 * -0.001,
    fontWeight: semiBold,
  );

  // Body
  static TextStyle body1 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 16,
    height: 26 / 16,
    letterSpacing: 0,
    fontWeight: regular,
  );

  static TextStyle body1Light = body1.copyWith(fontWeight: light);

  static TextStyle body2 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 14,
    height: 24 / 14,
    letterSpacing: 0,
    fontWeight: regular,
  );

  static TextStyle body2Light = body2.copyWith(fontWeight: light);

  // Paragraph
  static TextStyle paragraph1 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 13,
    height: 24 / 13,
    letterSpacing: 0,
    fontWeight: regular,
  );

  static TextStyle paragraph1Light = paragraph1.copyWith(fontWeight: light);

  static TextStyle paragraph2 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 12,
    height: 20 / 12,
    letterSpacing: 0,
    fontWeight: regular,
  );

  static TextStyle paragraph2Light = paragraph2.copyWith(fontWeight: light);

  // Caption
  static TextStyle caption = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 11,
    height: 18 / 11,
    letterSpacing: 0,
    fontWeight: regular,
  );

  static TextStyle captionLight = caption.copyWith(fontWeight: light);

  // Roboto Condensed Styles
  static const String _condensedFont = 'Roboto Condensed';

  static TextStyle title1Condensed = GoogleFonts.getFont(
    _condensedFont,
    fontSize: 28,
    height: 40 / 28,
    letterSpacing: 0,
    fontWeight: semiBold,
  );

  static TextStyle title2Condensed = GoogleFonts.getFont(
    _condensedFont,
    fontSize: 36,
    height: 48 / 36,
    letterSpacing: 0,
    fontWeight: semiBold,
  );
}
