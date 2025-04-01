import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:flutter/material.dart';
export 'dropdown_on_string.dart';

const Color defaultBorderColor = Colors.white;

class AilDropdownOnStringWidget extends StatefulWidget {
  final EdgeInsets? padding;
  final List<String>? items;
  final Function(String?)? onChange;
  final Function(String?)? validator;
  final String? defaultValue;
  final String? hint;
  final String? placeHolder;
  final double? height;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final Color? dropdownColor;
  final Color? fillColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool? showBorder;
  final Widget? icon;
  final String? title;
  final TextStyle? titleStyle;
  final bool giveVerticalPadding;
  final bool enabled;

  const AilDropdownOnStringWidget({
    Key? key,
    this.enabled = true,
    this.onChange,
    this.validator,
    this.placeHolder = '',
    this.defaultValue,
    required this.items,
    this.padding,
    this.height,
    this.hint = "Select",
    this.borderColor,
    this.borderRadius,
    this.showBorder = true,
    this.borderWidth,
    this.textStyle,
    this.fillColor,
    this.dropdownColor,
    this.hintStyle,
    this.icon,
    this.title,
    this.titleStyle,
    this.giveVerticalPadding = true,
  }) : super(key: key);

  @override
  State<AilDropdownOnStringWidget> createState() =>
      _AilDropdownOnStringWidgetState();
}

class _AilDropdownOnStringWidgetState extends State<AilDropdownOnStringWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.enabled
        ? SizedBox(
            height: widget.height ?? 36,
            child: DropdownButtonFormField<String>(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              value: widget.defaultValue,
              decoration: InputDecoration(
                contentPadding: widget.padding ??
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                filled: true,
                // enabled: widget.enabled,
                fillColor: widget.enabled
                    ? widget.fillColor
                    : Colors.black.withOpacity(0.1),
                focusedBorder: widget.showBorder == false
                    ? InputBorder.none
                    : OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? 8),
                        borderSide: BorderSide(
                          width: widget.borderWidth ?? 2,
                          color: widget.borderColor ?? defaultBorderColor,
                        ),
                      ),
                enabledBorder: widget.showBorder == false
                    ? InputBorder.none
                    : OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? 8),
                        borderSide: BorderSide(
                          width: widget.borderWidth ?? 2,
                          color: widget.borderColor ?? defaultBorderColor,
                        ),
                      ),
              ),
              alignment: Alignment.centerLeft,
              icon: widget.icon ?? const Icon(Icons.keyboard_arrow_down_sharp),
              isExpanded: true,
              isDense: true,
              style: AiloitteTheme().fonts.mediumStyle(
                    fontSize: 16,
                    fontColor: AiloitteTheme().colors.black,
                  ),
              onChanged: (String? newValue) {
                setState(() {
                  if (widget.onChange != null) {
                    widget.onChange!(newValue);
                  }
                });
              },
              validator: (val) => widget.validator?.call(val),
              dropdownColor: widget.dropdownColor,
              hint: Text(
                widget.hint ?? '',
                style: widget.hintStyle,
                textAlign: TextAlign.left,
              ),
              menuMaxHeight: MediaQuery.of(context).size.height / 2,
              items:
                  widget.items?.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    "$value${widget.placeHolder}",
                    textAlign: TextAlign.start,
                    style: widget.textStyle,
                  ),
                );
              }).toList(),
            ),
          )
        : Container(
            width: double.maxFinite,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.borderColor ?? defaultBorderColor,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              color: Colors.black.withOpacity(0.1),
            ),
            height: widget.height,
            padding: widget.padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.items?.isEmpty == true
                        ? ''
                        : widget.items?.first ?? '',
                    maxLines: 1,
                    style: widget.textStyle,
                  ),
                ),
                widget.icon ?? const Icon(Icons.keyboard_arrow_down_sharp),
              ],
            ),
          );
  }
}
