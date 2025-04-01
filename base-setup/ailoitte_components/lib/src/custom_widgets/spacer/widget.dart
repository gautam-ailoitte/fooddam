import 'package:flutter/cupertino.dart';

class AiloitteSpacerWidget extends StatelessWidget {
  final double? height, width;

  const AiloitteSpacerWidget({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 0,
      height: height ?? 0,
    );
  }
}
