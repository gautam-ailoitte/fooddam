import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:ailoitte_components/src/custom_widgets/image/core/type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AilCustomWidgets extends AiloitteTheme {

  PreferredSizeWidget appBar({
    final Key? key,
    final String? title,
    final TextStyle? titleStyle,
    final Function? callBack,
    final Widget? leading,
    final List<Widget>? actions,
    final Color? backgroundColor,
    final Gradient? gradient,
    final double? toolbarHeight,
    final bool? showBackButton,
    final bool? centerTitle,
  }) {
    return AiloitteAppBarWidget(
      key: key,
      title: title,
      titleStyle: titleStyle,
      callBack: callBack,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      gradient: gradient,
      toolbarHeight: toolbarHeight,
      showBackButton: showBackButton,
      centerTitle: centerTitle,
    );
  }

  Widget containedButton({
    final VoidCallback? onTap,
    final ValueNotifier<AiloitteButtonState>? buttonStateNotifier,
    final String? title,
    final TextStyle? titleStyle,
    final Widget? widget,
    final EdgeInsets? padding,
    final EdgeInsets? margin,
    final double? height,
    final double? width,
    final double? borderRadius,
    final Color? enabledColor,
    final Color? disabledColor,
    final double? loaderSize,
    final Color? loaderColor,
    final Color? borderColor,
    final bool? isPrefixedWidget,
  }) {
    return AiloitteContainedButtonWidget(
      buttonStateNotifier: buttonStateNotifier,
      isPrefixedWidget: isPrefixedWidget ?? false,
      title: title,
      borderRadius: borderRadius,
      height: height,
      onTap: onTap,
      padding: padding,
      width: width,
      enabledColor: enabledColor,
      disabledColor: disabledColor,
      loaderColor: loaderColor,
      loaderSize: loaderSize,
      titleStyle: titleStyle,
      margin: margin,
      borderColor: borderColor,
      widget: widget,
    );
  }

  Widget outlinedButton({
    final VoidCallback? onTap,
    final ValueNotifier<AiloitteButtonState>? buttonStateNotifier,
    final String? title,
    final TextStyle? titleStyle,
    final Widget? widget,
    final EdgeInsets? padding,
    final EdgeInsets? margin,
    final double? height,
    final double? width,
    final double? borderRadius,
    final double? borderWidth,
    final double? loaderSize,
    final Color? loaderColor,
    final Color? disabledColor,
    final Color? outlineBorderColor,
  }) {
    return AiloitteOutlinedButtonWidget(
      buttonStateNotifier: buttonStateNotifier,
      title: title,
      borderRadius: borderRadius,
      height: height,
      onTap: onTap,
      padding: padding,
      width: width,
      disabledColor: disabledColor,
      loaderColor: loaderColor,
      loaderSize: loaderSize,
      titleStyle: titleStyle,
      margin: margin,
      widget: widget,
      borderWidth: borderWidth,
      outlineBorderColor: outlineBorderColor,
    );
  }

  Widget textButton({
    required final String title,
    required final VoidCallback callback,
    final TextStyle? titleStyle,
    final bool showUnderline = false,
  }) {
    return AiloitteTextButtonWidget(
      title,
      callback: callback,
      titleStyle: titleStyle,
      showUnderline: showUnderline,
    );
  }

  Widget scaffold({
    final Key? key,
    final bool useSafeArea = true,
    final Function? onWillPop,
    final PreferredSizeWidget? appBar,
    final Widget? child,
    final Widget? bottomSheet,
    final Widget? bottomNavigationBar,
    final Widget? floatingActionButton,
    final FloatingActionButtonLocation? floatingActionButtonLocation,
    final bool? resizeToAvoidBottomInset,
    final Color? backgroundColor,
    final EdgeInsets? bodyPadding,
    final Widget? drawer,
  }) {
    return AiloitteScaffoldWidget(
      useSafeArea: useSafeArea,
      onWillPop: onWillPop,
      appBar: appBar,
      drawer: drawer,
      bottomSheet: bottomSheet,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      bodyPadding: bodyPadding ??
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
      child: child,
    );
  }

  Widget radioButton({
    final Key? key,
    required bool isSelected,
    required void Function() onTap,
    final String? title,
    final TextStyle? titleStyle,
    final double? gap,
    required final Color selectedColor,
  }) {
    return AiloitteRadioButtonWidget(
      key: key,
      isSelected: isSelected,
      onTap: onTap,
      title: title,
      titleStyle: titleStyle,
      gap: gap ?? 10,
      selectedColor: selectedColor,
    );
  }

  // Widget image({
  //   final Key? key,
  //   required final String image,
  //   required final AiloitteImageType type,
  //   final bool? isCircular,
  //   final double? borderRadius,
  //   final double? height,
  //   final double? width,
  //   final BoxFit? fit,
  //   final Widget? errorWidget,
  //   final Widget? loaderWidget,
  //   final double? imageRadius,
  // }) {
  //   return AiloitteImage(
  //     key: key,
  //     image: image,
  //     isCircular: isCircular ?? false,
  //     borderRadius: borderRadius ?? 0,
  //     height: height,
  //     width: width,
  //     fit: fit,
  //     errorWidget: errorWidget,
  //     loaderWidget: loaderWidget,
  //     imageRadius: imageRadius ?? 48,
  //     type: type,
  //   );
  // }

  Widget assetImage({
    final Key? key,
    required final String path,
    final bool isCircular = false,
    final double borderRadius = 0,
    final double? height,
    final double? width,
    final BoxFit? fit,
    final Widget? errorWidget,
    final Widget? loaderWidget,
    final double? imageRadius,
    final Color? color,
  }) {
    return AilAssetImageWidget(
      key: key,
      path: path,
      isCircular: isCircular,
      borderRadius: borderRadius,
      height: height,
      width: width,
      boxFit: fit,
      color: color,
      errorWidget: errorWidget,
      loaderWidget: loaderWidget,
      imageRadius: imageRadius ?? 48,
    );
  }

  Widget networkImage({
    final Key? key,
    required final String url,
    final bool isCircular = false,
    final double borderRadius = 0,
    final double? height,
    final double? width,
    final BoxFit? fit,
    final Widget? errorWidget,
    final Widget? loaderWidget,
    final double? imageRadius,
  }) {
    return AiloitteNetworkImageWidget(
      key: key,
      imageUrl: url,
      isCircular: isCircular,
      borderRadius: borderRadius,
      height: height,
      width: width,
      boxFit: fit,
      errorWidget: errorWidget,
      loaderWidget: loaderWidget,
      imageRadius: imageRadius ?? 48,
    );
  }

  Widget fileImage({
    final Key? key,
    required final String image,
    final bool isCircular = false,
    final double borderRadius = 0,
    final double? height,
    final double? width,
    final BoxFit? fit,
    final Widget? errorWidget,
    final Widget? loaderWidget,
    final double? imageRadius,
    final AiloitteImageType? type,
  }) {
    return AiloitteFileImageWidget(
      key: key,
      imagePath: image,
      isCircular: isCircular,
      borderRadius: borderRadius,
      height: height,
      width: width,
      boxFit: fit,
      errorWidget: errorWidget,
      loaderWidget: loaderWidget,
      imageRadius: imageRadius ?? 48,
      type: type,
    );
  }

  Widget divider({
    final Key? key,
    final Color? color,
    final double? height,
    final double? thickness,
    final double horizontalMargin = 0,
  }) {
    return AiloitteDividerWidget(
      key: key,
      color: color,
      height: height,
      thickness: thickness,
      horizontalMargin: horizontalMargin,
    );
  }

  Widget spacer({
    final Key? key,
    final double? height,
    final double? width,
  }) {
    return AiloitteSpacerWidget(
      height: height,
      width: width,
      key: key,
    );
  }

  Widget text(
    final String? text, {
    final Key? key,
    final TextStyle? style,
    final TextOverflow? overflow,
    final int? maxLines,
    final TextAlign? textAlign,
  }) {
    return AiloitteTextWidget(
      text,
      style: style,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      key: key,
    );
  }

  Widget textField({
    final Key? key,
    final String? labelText,
    final Widget? suffix,
    final TextStyle? labelStyle,
    required final TextEditingController controller,
    dynamic Function(String)? onChange,
    final TextStyle? style,
    final Widget? prefixWidget,
    final double? borderRadius,
    final String? hintText,
    final TextStyle? hintTextStyle,
    final Widget? suffixWidget,
    final bool? isEnabled,
    final Function? onTapCallback,
    final int? maxLines,
    final EdgeInsets? contentPadding,
    final TextInputType? textInputType,
    final List<TextInputFormatter>? inputFormatters,
    final TextCapitalization? textCapitalization,
    final Color? fillColor,
    final Function(bool)? focus,
    final String? Function(String?)? validator,
    final bool? showFocusedBorder,
    final FocusNode? focusNode,
    final Widget? prefix,
    final TextInputAction? textInputAction,
    final bool? obscureText,
    final String? headerText,
    final bool? isRequired,
    final InputDecoration? inputDecoration,
    final double? cursorWidth,
    final bool? filled,
    final bool? isDense,
    final TextStyle? errorStyle,
    final Color? borderColor,
    final Color? errorBorderColor,
    final Color? focusedBorderColor,
    final EdgeInsets? headerPadding,
    final TextStyle? headerStyle,
    final bool isDisposable = false,
    final int? maxLength,
    final int? minLines,
    final bool expands = false,
    final bool readOnly = false,
    final BoxConstraints? prefixIconConstraints,
    final BoxConstraints? suffixIconConstraints,
    final Widget? showObscureWidget,
    final Widget? hideObscureWidget,
  }) {
    return AiloitteTextFieldWidget(
      expands: expands,
      maxLength: maxLength,
      labelText: labelText,
      minLines: minLines,
      suffix: suffix,
      borderColor: borderColor,
      emptyBorderColor: borderColor,
      labelStyle: labelStyle,
      controller: controller,
      onChange: onChange,
      style: style,
      showObscureWidget: showObscureWidget,
      hideObscureWidget: hideObscureWidget,
      prefixWidget: prefixWidget,
      borderRadius: borderRadius ?? 8,
      hintText: hintText,
      hintTextStyle: hintTextStyle,
      suffixWidget: suffixWidget,
      isEnabled: isEnabled ?? true,
      onTapCallback: onTapCallback,
      prefixIconConstraints: prefixIconConstraints,
      maxLines: maxLines,
      contentPadding: kIsWeb
          ? contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          : contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      textInputType: textInputType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      fillColor: Colors.white,
      focus: focus,
      validator: validator,
      showFocusedBorder: showFocusedBorder ?? false,
      focusNode: focusNode,
      prefix: prefix,
      textInputAction: textInputAction ?? TextInputAction.done,
      obscureText: obscureText ?? false,
      headerText: headerText,
      isRequired: isRequired ?? false,
      inputDecoration: inputDecoration,
      cursorWidth: cursorWidth ?? 1,
      filled: filled ?? true,
      isDense: isDense ?? true,
      errorStyle: errorStyle,
      errorBorderColor: errorBorderColor,
      focusedBorderColor: focusedBorderColor,
      isDisposable: isDisposable,
      headerPadding: headerPadding ?? const EdgeInsets.only(bottom: 10),
      headerStyle: headerStyle,
      suffixIconConstraints:
          suffixIconConstraints ?? BoxConstraints.tight(const Size(90, 20)),

    );
  }

  Widget dropDownOfStringField({
    final EdgeInsets? padding,
    final List<String>? items,
    final Function(String?)? onChange,
    final String? defaultValue,
    final String? hint,
    final String? placeHolder,
    final double? height,
    final double? borderRadius,
    final double? borderWidth,
    final Color? borderColor,
    final Color? dropdownColor,
    final Color? fillColor,
    final TextStyle? textStyle,
    final bool? showBorder,
  }) {
    return AilDropdownOnStringWidget(
      items: items ?? [],
      padding: padding,
      defaultValue: defaultValue,
      height: height,
      hint: hint,
      onChange: onChange,
      placeHolder: placeHolder ?? '',
      borderColor: borderColor,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      dropdownColor: dropdownColor,
      fillColor: fillColor,
      showBorder: showBorder,
      textStyle: textStyle,
    );
  }

  Widget dropDownOfObjectField({
    final double? padding,
    final List<DropDownObject>? items,
    final Function(DropDownObject?)? onChange,
    final Function(DropDownObject?)? validator,
    final DropDownObject? defaultValue,
    final String? hint,
    final String? placeHolder,
    final double? height,
    final double? borderRadius,
    final double? borderWidth,
    final Color? borderColor,
  }) {
    return AilDropdownOnObjectsWidget(
      items: items ?? [],
      padding: padding,
      defaultValue: defaultValue,
      height: height,
      hint: hint,
      onChange: onChange,
      placeHolder: placeHolder,
      borderColor: borderColor,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      validator: (val) {
        if (validator != null) {
          validator(val);
        }
      },
    );
  }
}
