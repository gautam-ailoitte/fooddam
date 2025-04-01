import 'package:ailoitte_components/src/custom_widgets/button/core/type.dart';
import 'package:ailoitte_components/src/custom_widgets/button/core/widget.dart';
import 'package:flutter/material.dart';
import 'package:ailoitte_components/src/custom_widgets/button/state.dart';

class AiloitteOutlinedButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueNotifier<AiloitteButtonState>? buttonStateNotifier;
  final String? title;
  final TextStyle? titleStyle;
  final TextStyle? disabledTextStyle;
  final Widget? widget;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? borderWidth;
  final double? loaderSize;
  final Color? loaderColor;
  final Color? disabledColor;
  final Color? outlineBorderColor;
  final TextAlign? titleTextAlign;
  final bool showWidgetSpacer;
  final bool isPrefixedWidget;
  final Color? buttonColor;

  const AiloitteOutlinedButtonWidget({
    super.key,
    this.onTap,
    this.buttonStateNotifier,
    required this.title,
    this.titleStyle,
    this.padding,
    this.disabledTextStyle,
    this.margin,
    this.widget,
    this.height,
    this.width,
    this.borderRadius,
    this.borderWidth,
    this.loaderColor,
    this.loaderSize,
    this.disabledColor,
    this.outlineBorderColor,
    this.titleTextAlign,
    this.showWidgetSpacer = true,
    this.isPrefixedWidget = false,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return AiloitteButtonWidget(
      buttonColor: buttonColor,
      isPrefixedWidget: isPrefixedWidget,
      // titleTextAlign: titleTextAlign,
      disabledTextStyle: disabledTextStyle,
      buttonStateNotifier:
          buttonStateNotifier ?? ValueNotifier(AiloitteButtonState.active),
      type: AiloitteButtonType.outlined,
      title: title,
      borderRadius: borderRadius,
      height: height,
      onTap: onTap,
      contentPadding: padding,
      margin: margin,
      width: width,
      borderWidth: borderWidth,
      outlineBorderColor: outlineBorderColor,
      loaderColor: loaderColor,
      loaderSize: loaderSize,
      titleStyle: titleStyle,
      disabledColor: disabledColor,
      showWidgetSpacer: showWidgetSpacer,
      child: widget,
    );
  }
}
