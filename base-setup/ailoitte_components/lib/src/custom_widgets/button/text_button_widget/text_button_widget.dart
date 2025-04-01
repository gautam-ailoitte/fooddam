import 'package:ailoitte_components/src/custom_widgets/button/core/type.dart';
import 'package:ailoitte_components/src/custom_widgets/button/core/widget.dart';
import 'package:flutter/material.dart';

class AiloitteTextButtonWidget extends StatelessWidget {
  final VoidCallback callback;
  final String? title;
  final TextStyle? titleStyle;
  final bool showUnderline;
  const AiloitteTextButtonWidget(
    this.title, {
    required this.callback,
    this.titleStyle,
    this.showUnderline = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AiloitteButtonWidget(
      type: AiloitteButtonType.text,
      title: title ?? '',
      showUnderline: showUnderline,
      onTap: callback,
      titleStyle: titleStyle,
    );
  }
}
