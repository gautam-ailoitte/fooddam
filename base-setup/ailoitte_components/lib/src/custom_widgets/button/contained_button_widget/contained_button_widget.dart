import 'package:ailoitte_components/src/custom_widgets/button/core/type.dart';
import 'package:ailoitte_components/src/custom_widgets/button/core/widget.dart';
import 'package:ailoitte_components/src/custom_widgets/button/state.dart';
import 'package:flutter/material.dart';

class AiloitteContainedButtonWidget extends StatelessWidget {
  const AiloitteContainedButtonWidget({
    this.onTap,
    this.preTap,
    this.buttonStateNotifier,
    required this.title,
    this.titleStyle,
    this.padding,
    this.margin,
    this.isPrefixedWidget = false,
    this.widget,
    this.height,
    this.width,
    this.borderRadius,
    this.enabledColor,
    this.disabledColor,
    this.loaderColor,
    this.loaderSize,
    this.boxShadow,
    this.titleTextAlign,
    this.borderColor,
    this.disabledTextStyle,
    this.maxLines,
    this.elevation,
    super.key,
  });

  final VoidCallback? onTap;
  final VoidCallback? preTap;
  final ValueNotifier<AiloitteButtonState>? buttonStateNotifier;
  final String? title;
  final TextStyle? titleStyle;
  final Widget? widget;
  final bool isPrefixedWidget;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? enabledColor;
  final Color? disabledColor;
  final double? loaderSize;
  final Color? loaderColor;
  final List<BoxShadow>? boxShadow;
  final TextAlign? titleTextAlign;
  final Color? borderColor;
  final TextStyle? disabledTextStyle;
  final int? maxLines;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return AiloitteButtonWidget(
      elevation: elevation,
      disabledTextStyle: disabledTextStyle,
      maxLines: maxLines,
      // titleTextAlign: titleTextAlign,
      buttonStateNotifier:
          buttonStateNotifier ?? ValueNotifier(AiloitteButtonState.active),
      type: AiloitteButtonType.contained,
      title: title,
      borderRadius: borderRadius,
      height: height,
      onTap: onTap,
      preTap: preTap,
      contentPadding: padding,
      width: width,
      enabledColor: enabledColor,
      disabledColor: disabledColor,
      loaderColor: loaderColor,
      loaderSize: loaderSize,
      titleStyle: titleStyle,
      margin: margin,
      boxShadow: boxShadow,
      isPrefixedWidget: isPrefixedWidget,
      borderColor: borderColor,
      child: widget,
    );
  }
}
