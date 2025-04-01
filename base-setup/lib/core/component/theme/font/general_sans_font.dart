import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:flutter/material.dart';
import 'package:guardian_bubble/core/util/app_color.dart';

import '../../../../generated/app_asset.dart';

const String appFontGeneralSans = 'GeneralSans';

// thin 300
// regular 400
// medium 500
// semiBold 600
// bold 700
// extraBold 800
// black 900

class GeneralSansFont extends AiloitteFonts {
  GeneralSansFont()
      : super(
          defaultFontSize: defaultFontSize,
          defaultLetterSpacing: defaultLetterSpacing,
          defaultWordSpacing: defaultWordSpacing,
          defaultHeight: defaultHeight,
          defaultFontType: defaultFontType ?? appFontGeneralSans,
          defaultFontColor: defaultFontColor,
          defaultDecoration: defaultDecoration,
          defaultBackgroundColor: defaultBackgroundColor,
        );

  static double? defaultFontSize = 14;
  static double? defaultLetterSpacing;
  static double? defaultWordSpacing;
  static double? defaultHeight;
  static String? defaultFontType = appFontGeneralSans;
  static Color defaultFontColor = AppColor.black;
  static TextDecoration? defaultDecoration;
  static Color? defaultBackgroundColor;

  @override
  TextStyle thinStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    final FontWeight? fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
    final Paint? foreground,
  }) {
    return customStyle(
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w300,
      fontColor: fontColor,
      backgroundColor: backgroundColor,
      decoration: decoration,
      fontType: fontType ?? AppAsset.fontGeneralSansLight,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      foreground: foreground,
    );
  }

  @override
  TextStyle regularStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    final FontWeight? fontWeight,
    final TextDecoration? decoration,
    final Color? decorationColor,
    final Color? backgroundColor,
    final Paint? foreground,
  }) {
    return customStyle(
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w400,
      fontColor: fontColor,
      backgroundColor: backgroundColor,
      decoration: decoration,
      decorationColor: decorationColor,
      fontType: fontType ?? AppAsset.fontGeneralSansRegular,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      foreground: foreground,
    );
  }

  @override
  TextStyle mediumStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    final FontWeight? fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
    final Paint? foreground,
  }) {
    return customStyle(
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w500,
      fontColor: fontColor,
      backgroundColor: backgroundColor,
      decoration: decoration,
      fontType: fontType ?? AppAsset.fontGeneralSansMedium,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      foreground: foreground,
    );
  }

  @override
  TextStyle semiBoldStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    final FontWeight? fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
    final Paint? foreground,
  }) {
    return customStyle(
      fontSize: fontSize ?? 20,
      fontWeight: FontWeight.w600,
      fontColor: fontColor,
      backgroundColor: backgroundColor,
      decoration: decoration,
      fontType: fontType ?? AppAsset.fontGeneralSansSemibold,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      foreground: foreground,
    );
  }

  @override
  TextStyle boldStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    final FontWeight? fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
    final Paint? foreground,
  }) {
    return customStyle(
        fontSize: fontSize ?? 24,
        fontWeight: FontWeight.w700,
        fontColor: fontColor,
        backgroundColor: backgroundColor,
        decoration: decoration,
        fontType: fontType ?? AppAsset.fontGeneralSansBold,
        height: height,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        foreground: foreground);
  }

  @override
  TextStyle extraBoldStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    final FontWeight? fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
    final Paint? foreground,
  }) {
    return customStyle(
      fontSize: fontSize ?? 24,
      fontWeight: FontWeight.w800,
      fontColor: fontColor,
      backgroundColor: backgroundColor,
      decoration: decoration,
      fontType: fontType ?? AppAsset.fontGeneralSansVariable,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      foreground: foreground,
    );
  }

  @override
  TextStyle blackStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    final FontWeight? fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
    final Paint? foreground,
  }) {
    return customStyle(
      fontSize: fontSize ?? 24,
      fontWeight: FontWeight.w900,
      fontColor: fontColor,
      backgroundColor: backgroundColor,
      decoration: decoration,
      fontType: fontType ?? AppAsset.fontGeneralSansBold,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      foreground: foreground,
    );
  }
}
