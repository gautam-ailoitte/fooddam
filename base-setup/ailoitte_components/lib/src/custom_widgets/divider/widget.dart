import 'package:flutter/material.dart';

class AiloitteDividerWidget extends StatelessWidget {
  const AiloitteDividerWidget({
    Key? key,
    this.color,
    this.height,
    this.thickness,
    this.horizontalMargin = 0,
  }) : super(key: key);

  final Color? color;
  final double? height;
  final double? thickness;
  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Divider(
        height: height,
        color: color,
        thickness: thickness,
      ),
    );
  }
}
