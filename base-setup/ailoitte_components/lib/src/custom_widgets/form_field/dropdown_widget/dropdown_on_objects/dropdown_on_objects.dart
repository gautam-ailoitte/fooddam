import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:flutter/material.dart';

class AilDropdownOnObjectsWidget extends StatefulWidget {
  final double? padding;
  final List<DropDownObject>? items;
  final Function(DropDownObject?)? onChange;
  final Function(DropDownObject?) validator;
  final DropDownObject? defaultValue;
  final String? hint;
  final String? placeHolder;
  final double? height;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final Color? dropdownColor;
  final Color? fillColor;
  final TextStyle? textStyle;
  final TextStyle? errorStyle;
  final Widget? arrowIcon;

  const AilDropdownOnObjectsWidget({
    Key? key,
    this.onChange,
    this.placeHolder = '',
    this.arrowIcon,
    this.defaultValue,
    required this.items,
    required this.validator,
    this.padding = 20,
    this.height = 40,
    this.hint = "Select",
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.textStyle,
    this.errorStyle,
    this.fillColor,
    this.dropdownColor,
  }) : super(key: key);

  @override
  State<AilDropdownOnObjectsWidget> createState() =>
      _AilDropdownOnObjectsWidgetState();
}

class _AilDropdownOnObjectsWidgetState
    extends State<AilDropdownOnObjectsWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: DropdownButtonFormField<DropDownObject>(
        value: widget.defaultValue,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.fillColor,
          errorStyle: widget.errorStyle,
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.padding ?? 12,
            vertical: 14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            borderSide: BorderSide(
              width: widget.borderWidth ?? 2,
              color: widget.borderColor ?? defaultBorderColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            borderSide: BorderSide(
              width: widget.borderWidth ?? 2,
              color: widget.borderColor ?? defaultBorderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            borderSide: BorderSide(
              width: widget.borderWidth ?? 2,
              color: widget.borderColor ?? defaultBorderColor,
            ),
          ),
        ),
        alignment: Alignment.centerLeft,
        // TODO:Himmat add asset image if available
        icon: widget.arrowIcon ?? const Icon(Icons.keyboard_arrow_down_sharp),
        elevation: 0,
        isExpanded: true,
        style: AiloitteTheme().fonts.mediumStyle(
              fontSize: 16,
              fontColor: AiloitteTheme().colors.text,
            ),
        onChanged: (DropDownObject? newValue) {
          setState(() {
            if (widget.onChange != null) {
              widget.onChange?.call(newValue);
            }
          });
        },
        validator: (val) => widget.validator(val),
        dropdownColor: widget.dropdownColor,
        isDense: true,

        hint: Text(
          widget.hint ?? '',
          textAlign: TextAlign.left,
        ),
        menuMaxHeight: MediaQuery.of(context).size.height / 2,
        items: widget.items
            ?.map<DropdownMenuItem<DropDownObject>>((DropDownObject value) {
          return DropdownMenuItem<DropDownObject>(
            value: value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value.itemName,
                    textAlign: TextAlign.start,
                    style: widget.textStyle,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
