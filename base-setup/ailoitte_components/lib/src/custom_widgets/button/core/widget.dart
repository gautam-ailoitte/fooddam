import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:ailoitte_components/src/custom_widgets/button/core/type.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

const Color defaultEnabledColor = Color(0xFF004FEB);
const Color defaultDisabledColor = Color(0xFFB4B4B4);
const Color defaultContainedLoaderColor = Color(0xFFFFFFFF);
const Color defaultOutlinedLoaderColor = Color(0xFF000000);
const Color defaultOutlineBorderColor = Color(0xFF000000);
const double defaultHeight = 56;
const double defaultLoaderSize = 22;
const double defaultBorderRadius = 320;
const double defaultBorderWidth = 2;

class AiloitteButtonWidget extends StatefulWidget {
  const AiloitteButtonWidget({
    Key? key,
    this.onTap,
    this.preTap,
    required this.type,
    this.buttonStateNotifier,
    this.title,
    this.contentPadding,
    this.width,
    this.height,
    this.child,
    this.isPrefixedWidget = false,
    this.loadingTitle,
    this.titleStyle,
    this.loadingTitleStyle,
    this.borderRadius,
    this.enabledColor,
    this.disabledColor,
    this.loaderColor,
    this.loaderSize,
    this.outlineBorderColor,
    this.outlineBorderWidth,
    this.showUnderline = false,
    this.borderWidth,
    this.margin,
    this.boxShadow,
    this.titleTextAlign,
    this.borderColor,
    this.maxLines,
    this.disabledTextStyle,
    this.showWidgetSpacer = true,
    this.buttonColor,
    this.elevation,
  }) : super(key: key);
  final AiloitteButtonType type;
  final VoidCallback? onTap;
  final VoidCallback? preTap;
  final ValueNotifier<AiloitteButtonState>? buttonStateNotifier;
  final String? title;
  final Widget? child;
  final bool isPrefixedWidget;
  final String? loadingTitle;
  final TextStyle? titleStyle;
  final TextStyle? loadingTitleStyle;
  final EdgeInsets? contentPadding;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? enabledColor;
  final Color? disabledColor;
  final Color? loaderColor;
  final double? loaderSize;
  final Color? outlineBorderColor;
  final double? outlineBorderWidth;
  final bool showUnderline;
  final EdgeInsets? margin;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final TextAlign? titleTextAlign;
  final Color? borderColor;
  final TextStyle? disabledTextStyle;
  final bool showWidgetSpacer;
  final int? maxLines;
  final Color? buttonColor;
  final double? elevation;

  @override
  State<AiloitteButtonWidget> createState() => _AiloitteButtonWidgetState();
}

class _AiloitteButtonWidgetState extends State<AiloitteButtonWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case AiloitteButtonType.text:
        {
          return InkWell(
            onTap: widget.onTap,
            child: AiloitteTextWidget(
              widget.title,
              style: widget.showUnderline
                  ? (widget.titleStyle ?? const TextStyle()).copyWith(
                      decoration: TextDecoration.underline,
                    )
                  : widget.titleStyle,
            ),
          );
        }
      case AiloitteButtonType.contained:
        {
          return ValueListenableBuilder(
            valueListenable: widget.buttonStateNotifier ??
                ValueNotifier(AiloitteButtonState.active),
            builder: (
              context,
              AiloitteButtonState state,
              Widget? notifierWidget,
            ) {
              return Padding(
                padding: widget.margin ?? EdgeInsets.zero,
                child: Material(
                  elevation: widget.elevation ?? 0,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? defaultBorderRadius,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? defaultBorderRadius,
                    ),
                    onTap: () {
                      // Fluttertoast.cancel();
                      widget.preTap?.call();
                      if (widget.buttonStateNotifier?.value ==
                          AiloitteButtonState.disabled) {
                        return;
                      }
                      if (widget.buttonStateNotifier?.value ==
                          AiloitteButtonState.loading) {
                        return;
                      }

                      widget.onTap?.call();
                    },
                    child: Ink(
                      width: widget.width,
                      //margin: widget.margin,
                      padding: widget.contentPadding,
                      //height: widget.height ?? defaultHeight,
                      //alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.buttonStateNotifier?.value ==
                                AiloitteButtonState.disabled
                            ? widget.disabledColor ?? defaultDisabledColor
                            : widget.enabledColor ?? defaultEnabledColor,
                        boxShadow: widget.boxShadow,
                        border: widget.borderColor != null
                            ? Border.all(
                                width: 1,
                                color: widget.borderColor ?? Colors.transparent,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius ?? defaultBorderRadius,
                        ),
                      ),
                      child: widget.buttonStateNotifier?.value ==
                              AiloitteButtonState.loading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LoadingAnimationWidget.fourRotatingDots(
                                  color: widget.loaderColor ??
                                      defaultContainedLoaderColor,
                                  size: widget.loaderSize ?? defaultLoaderSize,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (widget.child != null &&
                                    widget.isPrefixedWidget)
                                  Row(
                                    children: [
                                      widget.child!,
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                Flexible(
                                  child: Text(
                                    widget.title ?? '',
                                    maxLines: widget.maxLines,
                                    overflow: TextOverflow.ellipsis,
                                    style: widget.buttonStateNotifier?.value ==
                                            AiloitteButtonState.disabled
                                        ? widget.disabledTextStyle ??
                                            widget.titleStyle
                                        : widget.titleStyle ??
                                            AiloitteTheme().fonts.regularStyle(
                                                  fontColor: Colors.white,
                                                  height: 26,
                                                  fontSize: 18,
                                                ),
                                  ),
                                ),
                                if (widget.child != null &&
                                    !widget.isPrefixedWidget)
                                  Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      widget.child!,
                                    ],
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      case AiloitteButtonType.outlined:
        {
          return ValueListenableBuilder(
            valueListenable: widget.buttonStateNotifier ??
                ValueNotifier(AiloitteButtonState.active),
            builder: (
              context,
              AiloitteButtonState state,
              Widget? notifierWidget,
            ) {
              return Padding(
                padding: widget.margin ?? EdgeInsets.zero,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius ?? defaultBorderRadius,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? defaultBorderRadius,
                    ),
                    onTap: () {
                      if (widget.buttonStateNotifier?.value ==
                          AiloitteButtonState.disabled) {
                        return;
                      }
                      widget.onTap?.call();
                    },
                    child: Ink(
                      width: widget.width,
                      // height: widget.height ?? defaultHeight,
                      //margin: widget.margin,
                      padding: widget.contentPadding,
                      //alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.buttonColor,
                        border: Border.all(
                          width: widget.borderWidth ?? defaultBorderWidth,
                          color: _getDisabledBorderColor(),
                        ),
                        boxShadow: widget.boxShadow,
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius ?? defaultBorderRadius,
                        ),
                      ),
                      child: widget.buttonStateNotifier?.value ==
                              AiloitteButtonState.loading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LoadingAnimationWidget.fourRotatingDots(
                                  color: widget.loaderColor ??
                                      defaultOutlinedLoaderColor,
                                  size: widget.loaderSize ?? defaultLoaderSize,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.child != null &&
                                    widget.isPrefixedWidget)
                                  Row(
                                    children: [
                                      widget.child!,
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                Flexible(
                                  child: AiloitteTextWidget(
                                    widget.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: widget.buttonStateNotifier?.value ==
                                            AiloitteButtonState.disabled
                                        ? widget.disabledTextStyle ??
                                            AiloitteTheme().fonts.mediumStyle(
                                                  fontSize: 14,
                                                  fontColor:
                                                      widget.buttonStateNotifier
                                                                  ?.value ==
                                                              AiloitteButtonState
                                                                  .disabled
                                                          ? defaultDisabledColor
                                                          : defaultEnabledColor,
                                                )
                                        : widget.titleStyle ??
                                            AiloitteTheme().fonts.mediumStyle(
                                                  fontSize: 14,
                                                  fontColor:
                                                      widget.buttonStateNotifier
                                                                  ?.value ==
                                                              AiloitteButtonState
                                                                  .disabled
                                                          ? defaultDisabledColor
                                                          : defaultEnabledColor,
                                                ),
                                  ),
                                ),
                                if (widget.child != null &&
                                    !widget.isPrefixedWidget)
                                  Row(
                                    children: [
                                      widget.child!,
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          );
        }
    }
  }

  Color _getDisabledBorderColor() {
    if (widget.outlineBorderColor == null) {
      if (widget.buttonStateNotifier?.value == AiloitteButtonState.disabled) {
        return defaultDisabledColor;
      } else {
        return defaultEnabledColor;
      }
    } else {
      return widget.outlineBorderColor!;
    }
  }
}
