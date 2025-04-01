import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextfieldEnum {
  error,
  filled,
  empty,
}

class AiloitteTextFieldWidget extends StatefulWidget {
  final FocusNode? focusNode;
  final TextEditingController controller;
  final Function(String)? onChange;
  final Widget? prefixWidget;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? suffixWidget;
  final double borderRadius;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final TextStyle? style;
  final TextInputType textInputType;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool isEnabled;
  final Function? onTapCallback;
  final int? maxLines;
  final EdgeInsets contentPadding;
  final Color? fillColor;
  final Color? errorFillColor;
  final Function(bool)? focus;
  final String? Function(String?)? validator;
  final bool showFocusedBorder;
  final TextInputAction textInputAction;
  final bool obscureText;
  final String? labelText;
  final TextStyle? labelStyle;
  final String? headerText;
  final bool isRequired;
  final InputDecoration? inputDecoration;
  final double cursorWidth;
  final bool filled;
  final bool isDense;
  final bool isDisposable;
  final TextStyle? errorStyle;
  final Color? borderColor;
  final Color? emptyBorderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final EdgeInsets headerPadding;
  final TextStyle? headerStyle;
  final int? maxLength;
  final int? minLines;
  final bool expands;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final bool showCounterText;
  final String? counterText;
  final TextStyle? helperTextStyle;
  final String? helperText;
  final double? borderWidth;
  final ValueNotifier<TextfieldEnum>? textfieldEnum;
  final Widget? errorSuffixWidget;
  final Color? successFillColor;
  final Widget? showObscureWidget;
  final Widget? hideObscureWidget;
  final bool showHelperText;
  final VoidCallback? onEditingComplete;
  final Function(String? val)? onFieldSubmitted;
  final bool readOnly;
  final MouseCursor? mouseCursor;
  final Color? hoverColor;
  final EdgeInsets? scrollPadding;

  const AiloitteTextFieldWidget({
    Key? key,
    this.labelText,
    this.helperText,
    this.showHelperText = false,
    this.counterText,
    this.showCounterText = false,
    this.suffix,
    this.labelStyle,
    required this.controller,
    this.onChange,
    this.style,
    this.prefixWidget,
    this.borderRadius = 8,
    this.hintText,
    this.hintTextStyle,
    this.suffixWidget,
    this.isEnabled = true,
    this.onTapCallback,
    this.maxLines,
    this.scrollPadding,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.textInputType = TextInputType.text,
    this.inputFormatters,
    this.textCapitalization,
    this.fillColor,
    this.focus,
    this.validator,
    this.showFocusedBorder = true,
    this.focusNode,
    this.prefix,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.headerText,
    this.isRequired = false,
    this.inputDecoration,
    this.cursorWidth = 1,
    this.filled = true,
    this.isDense = true,
    this.isDisposable = true,
    this.errorStyle,
    this.borderColor,
    this.borderWidth,
    this.errorBorderColor,
    this.focusedBorderColor,
    this.headerPadding = const EdgeInsets.only(bottom: 10),
    this.headerStyle,
    this.maxLength,
    this.minLines,
    this.expands = false,
    this.helperTextStyle,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.errorFillColor,
    this.textfieldEnum,
    this.errorSuffixWidget,
    this.successFillColor,
    this.showObscureWidget,
    this.hideObscureWidget,
    this.emptyBorderColor,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.mouseCursor,
    this.hoverColor,
  }) : super(key: key);

  @override
  State<AiloitteTextFieldWidget> createState() =>
      _AiloitteTextFieldWidgetState();
}

class _AiloitteTextFieldWidgetState extends State<AiloitteTextFieldWidget> {
  late final FocusNode _focus;

  bool _showPassword = false;

  @override
  void initState() {
    _showPassword = widget.obscureText;
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isDisposable) {
      widget.controller.dispose();
      _focus.removeListener(_onFocusChange);
      _focus.dispose();
      widget.focusNode?.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focus != null) {
      widget.focus!(_focus.hasFocus);

      (_focus.hasFocus);
    } else {
      false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable:
          widget.textfieldEnum ?? ValueNotifier(TextfieldEnum.empty),
      builder: (context, state, _) {
        return TextFormField(
          scrollPadding: widget.scrollPadding != null
              ? widget.scrollPadding!
              : const EdgeInsets.all(20),
          key: widget.key,
          mouseCursor: widget.mouseCursor,
          focusNode: _focus,
          readOnly: widget.readOnly,
          enabled: widget.isEnabled,
          controller: widget.controller,
          textInputAction: widget.textInputAction,
          obscureText: _showPassword,
          onChanged: (value) {
            if (widget.onChange != null) {
              widget.onChange!(value);
            }

            setState(() {});
          },
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onFieldSubmitted: (val) {
            if (widget.onFieldSubmitted != null) {
              widget.onFieldSubmitted!(val);
            }
          },
          onEditingComplete: widget.onEditingComplete,
          textAlignVertical: TextAlignVertical.center,
          style: widget.style,
          textAlign: TextAlign.left,
          cursorWidth: widget.cursorWidth,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.sentences,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.textInputType,
          maxLength: widget.maxLength,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          expands: widget.expands,
          obscuringCharacter: '∗',
          onTap: () {
            if (widget.onTapCallback != null) {
              widget.onTapCallback!();
            }
          },
          validator: widget.validator,
          decoration: widget.textfieldEnum?.value != TextfieldEnum.error
              ? widget.inputDecoration ??
                  InputDecoration(
                    hoverColor: widget.hoverColor ?? Colors.transparent,
                    helperStyle: widget.helperTextStyle,
                    helperText:
                        widget.showHelperText ? widget.helperText : null,
                    counterText:
                        widget.showCounterText ? widget.counterText ?? '' : '',
                    labelStyle: widget.labelStyle,
                    label: widget.labelText != null
                        ? Text(widget.labelText!)
                        : null,
                    isDense: widget.isDense,
                    contentPadding: widget.contentPadding,
                    prefixIcon: widget.prefixWidget,
                    hintStyle: widget.hintTextStyle,
                    hintText: widget.hintText ?? "",
                    errorStyle: widget.errorStyle,
                    prefixIconConstraints: widget.prefixIconConstraints,
                    errorMaxLines: 3,
                    suffixIconConstraints: widget.suffixIconConstraints ??
                        const BoxConstraints(
                          maxHeight: 20,
                          maxWidth: 40,
                          minHeight: 20,
                          minWidth: 40,
                        ),
                    prefix: widget.prefix,
                    suffix: widget.suffix,
                    suffixIcon: widget.obscureText
                        ? Row(
                            children: [
                              Builder(
                                builder: (context) {
                                  if (_showPassword) {
                                    return InkWell(
                                      onTap: () {
                                        _showPassword = false;
                                        setState(() {});
                                      },
                                      child: widget.showObscureWidget ??
                                          Icon(Icons.visibility),
                                    );
                                  } else {
                                    return InkWell(
                                      onTap: () {
                                        _showPassword = true;
                                        setState(() {});
                                      },
                                      child: widget.hideObscureWidget ??
                                          Icon(Icons.visibility_off),
                                    );
                                  }
                                },
                              ),
                              if (widget.suffixWidget != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: widget.suffixWidget!,
                                ),
                            ],
                          )
                        : widget.suffixWidget,
                    filled: widget.filled,
                    fillColor: widget.isEnabled
                        ? widget.fillColor
                        : Colors.black.withOpacity(0.1),
                    border: _getBorder(),
                    focusedBorder: _getFocusedBorder(),
                    enabledBorder: _getBorder(),
                    errorBorder: _getErrorBorder(),
                    focusedErrorBorder: _getBorder(),
                    disabledBorder: _getBorder(),
                  )
              : InputDecoration(
                  focusedErrorBorder: _getErrorBorder(),
                  helperStyle: widget.helperTextStyle,
                  hoverColor: widget.hoverColor ?? Colors.transparent,
                  helperText: widget.showHelperText ? widget.helperText : null,
                  counterText:
                      widget.showCounterText ? widget.counterText ?? '' : '',
                  labelStyle: widget.labelStyle,
                  label:
                      widget.labelText != null ? Text(widget.labelText!) : null,
                  isDense: widget.isDense,
                  contentPadding: widget.contentPadding,
                  prefixIcon: widget.prefixWidget,
                  hintStyle: widget.hintTextStyle,
                  hintText: widget.hintText ?? "",
                  errorStyle: widget.errorStyle,
                  prefixIconConstraints: widget.prefixIconConstraints,
                  errorMaxLines: 3,
                  suffixIconConstraints: const BoxConstraints(
                    maxHeight: 20,
                    maxWidth: 60,
                    minHeight: 20,
                    minWidth: 40,
                  ),
                  prefix: widget.prefix,
                  suffix: widget.suffix,
                  suffixIcon: widget.obscureText
                      ? Row(
                          children: [
                            Builder(
                              builder: (context) {
                                if (_showPassword) {
                                  return InkWell(
                                    onTap: () {
                                      _showPassword = false;
                                      setState(() {});
                                    },
                                    child:
                                        widget.showObscureWidget ?? Container(),
                                  );
                                } else {
                                  return InkWell(
                                    onTap: () {
                                      _showPassword = true;
                                      setState(() {});
                                    },
                                    child:
                                        widget.hideObscureWidget ?? Container(),
                                  );
                                }
                              },
                            ),
                            if (widget.errorSuffixWidget != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: widget.errorSuffixWidget!,
                              ),
                          ],
                        )
                      : widget.errorSuffixWidget,
                  filled: widget.filled,
                  fillColor: widget.errorFillColor,
                  border: _getErrorBorder(),
                  focusedBorder: _getFocusedBorder(),
                  enabledBorder: _getErrorBorder(),
                  errorBorder: _getErrorBorder(),
                  disabledBorder: _getBorder(),
                ),
        );
      },
    );
  }

  OutlineInputBorder? _getBorder() {
    if (widget.borderColor == null) return null;

    return OutlineInputBorder(
      borderSide: BorderSide(
        color: widget.filled
            ? widget.borderColor ?? defaultBorderColor
            : widget.emptyBorderColor ?? Colors.blue,
      ),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );
  }

  OutlineInputBorder? _getFocusedBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        width: 1,
        color: widget.focusedBorderColor ?? defaultBorderColor,
      ),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );
  }

  OutlineInputBorder? _getErrorBorder() {
    if (widget.errorBorderColor == null) return null;

    return OutlineInputBorder(
      borderSide: BorderSide(
        width: widget.borderWidth ?? 1,
        color: widget.errorBorderColor ?? Colors.red,
      ),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );
  }
}
