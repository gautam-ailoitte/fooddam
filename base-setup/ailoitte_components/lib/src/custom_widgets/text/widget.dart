import 'package:flutter/material.dart';

class AiloitteTextWidget extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  const AiloitteTextWidget(
    this.text, {
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      style: style,
    );
  }
}
