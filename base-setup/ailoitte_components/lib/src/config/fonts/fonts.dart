import 'package:flutter/material.dart';

/*
Default Font Properties for every font can be sent through the application.

All pre defined styles have some fixed weights such as:
thinStyle: w300
regularStyle: w400
mediumStyle: w500
semiBoldStyle: w600
boldStyle: w700
extraBoldStyle: w800
blackStyle: w900
customStyle: Flutter Default

 */

class AiloitteFonts {
  AiloitteFonts({
    double? defaultFontSize,
    double? defaultLetterSpacing,
    double? defaultWordSpacing,
    double? defaultHeight,
    String? defaultFontType,
    Color defaultFontColor = const Color(0xff000000),
    TextDecoration? defaultDecoration,
    Color? defaultBackgroundColor,
  })  : _defaultFontSize = defaultFontSize,
        _defaultLetterSpacing = defaultLetterSpacing,
        _defaultWordSpacing = defaultWordSpacing,
        _defaultHeight = defaultHeight,
        _defaultFontType = defaultFontType,
        _defaultFontColor = defaultFontColor,
        _defaultDecoration = defaultDecoration,
        _defaultBackgroundColor = defaultBackgroundColor;

  final double? _defaultFontSize;
  final double? _defaultLetterSpacing;
  final double? _defaultWordSpacing;
  final double? _defaultHeight;
  final String? _defaultFontType;
  final Color _defaultFontColor;
  final TextDecoration? _defaultDecoration;
  final Color? _defaultBackgroundColor;

  AiloitteFonts copyWith({
    double? defaultFontSize,
    double? defaultLetterSpacing,
    double? defaultWordSpacing,
    double? defaultHeight,
    String? defaultFontType,
    Color? defaultFontColor,
    TextDecoration? defaultDecoration,
    Color? defaultBackgroundColor,
  }) =>
      AiloitteFonts(
        defaultFontSize: defaultFontSize ?? _defaultFontSize,
        defaultLetterSpacing: defaultLetterSpacing ?? _defaultLetterSpacing,
        defaultWordSpacing: defaultWordSpacing ?? _defaultWordSpacing,
        defaultHeight: defaultHeight ?? _defaultHeight,
        defaultFontType: defaultFontType ?? _defaultFontType,
        defaultFontColor: defaultFontColor ?? _defaultFontColor,
        defaultDecoration: defaultDecoration ?? _defaultDecoration,
        defaultBackgroundColor:
            defaultBackgroundColor ?? _defaultBackgroundColor,
      );

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
  }) {
    return _getTextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontType: fontType,
      fontColor: fontColor,
      fontWeight: FontWeight.w900,
      decoration: decoration,
      backgroundColor: backgroundColor,
    );
  }

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
  }) {
    return _getTextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontType: fontType,
      fontColor: fontColor,
      fontWeight: FontWeight.w800,
      decoration: decoration,
      backgroundColor: backgroundColor,
    );
  }

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
    return _getTextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontType: fontType,
      fontColor: fontColor,
      fontWeight: FontWeight.w700,
      decoration: decoration,
      backgroundColor: backgroundColor,
      foreground: foreground,
    );
  }

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
  }) {
    return _getTextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontType: fontType,
      fontColor: fontColor,
      fontWeight: FontWeight.w600,
      decoration: decoration,
      backgroundColor: backgroundColor,
    );
  }

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
  }) {
    return _getTextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontType: fontType,
      fontColor: fontColor,
      fontWeight: FontWeight.w500,
      decoration: decoration,
      backgroundColor: backgroundColor,
    );
  }

  TextStyle regularStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    final FontWeight? fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
  }) {
    return _getTextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontType: fontType,
      fontColor: fontColor,
      fontWeight: FontWeight.w400,
      decoration: decoration,
      backgroundColor: backgroundColor,
    );
  }

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
  }) {
    return _getTextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontType: fontType,
      fontColor: fontColor,
      fontWeight: FontWeight.w300,
      decoration: decoration,
      backgroundColor: backgroundColor,
    );
  }

  TextStyle customStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    required final FontWeight fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
    final Color? decorationColor,
    final Paint? foreground,
    final TextOverflow? textOverflow,
  }) {
    return _getTextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontType: fontType,
      fontColor: fontColor,
      fontWeight: fontWeight,
      decoration: decoration,
      backgroundColor: backgroundColor,
      foreground: foreground,
      textOverflow: textOverflow,
      decorationColor: decorationColor,
    );
  }

  TextStyle _getTextStyle({
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
    final Color? decorationColor,
    final TextOverflow? textOverflow,
  }) {
    // assert(fontSize != null, "Set By Default 14 font size");
    // assert(
    //   height == null || height / (fontSize ?? 14) >= 1.2,
    //   "Line height must be greater then 1.2. By Default 1.2 ",
    // );
    assert(
      height == null || height / (fontSize ?? 14) < 4,
      "Line Height is greater then 4",
    );
    final double? heightMetrics =
        height == null ? null : height / (fontSize ?? 14);
    Paint? paint;
    if (backgroundColor != null || _defaultBackgroundColor != null) {
      paint = Paint();
      paint.color = backgroundColor ?? (_defaultBackgroundColor!);
    }

    return TextStyle(
      fontSize: fontSize ?? _defaultFontSize,
      letterSpacing: letterSpacing ?? _defaultLetterSpacing,
      wordSpacing: wordSpacing ?? _defaultWordSpacing,
      fontFamily: fontType ?? _defaultFontType,
      color: foreground != null ? null : fontColor ?? _defaultFontColor,
      fontWeight: fontWeight,
      height: heightMetrics,
      decoration: decoration ?? _defaultDecoration,
      background: paint,
      foreground: foreground,
      overflow: textOverflow,
      decorationColor: decorationColor,
    );
  }

  static TextStyle myCustomStyle({
    final double? fontSize,
    final double? letterSpacing,
    final double? wordSpacing,
    final double? height,
    final String? fontType,
    final Color? fontColor,
    required final FontWeight fontWeight,
    final TextDecoration? decoration,
    final Color? backgroundColor,
    final Paint? foreground,
  }) {
    late Paint paint;
    if (backgroundColor != null) {
      paint = Paint();
      paint.color = backgroundColor;
    }
    return TextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing ?? 0,
      wordSpacing: wordSpacing,
      fontFamily: fontType,
      color: foreground != null ? null : fontColor,
      fontWeight: fontWeight,
      decoration: decoration,
      background: paint,
      foreground: foreground,
    );
  }
}
