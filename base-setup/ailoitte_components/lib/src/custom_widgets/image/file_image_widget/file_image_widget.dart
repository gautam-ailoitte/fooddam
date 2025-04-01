import 'package:ailoitte_components/src/custom_widgets/image/core/type.dart';
import 'package:ailoitte_components/src/custom_widgets/image/core/widget.dart';
import 'package:flutter/material.dart';

class AiloitteFileImageWidget extends StatefulWidget {
  const AiloitteFileImageWidget({
    Key? key,
    required this.imagePath,
    this.boxFit,
    this.errorWidget,
    this.loaderWidget,
    this.isCircular = false,
    this.borderRadius = 0,
    this.height,
    this.width,
    this.imageRadius = 48,
    this.type,
  }) : super(key: key);

  final String imagePath;
  final BoxFit? boxFit;
  final Widget? errorWidget;
  final Widget? loaderWidget;
  final bool isCircular;
  final double borderRadius;
  final double imageRadius;
  final double? height;
  final double? width;
  final AiloitteImageType? type;

  @override
  AiloitteFileImageWidgetState createState() => AiloitteFileImageWidgetState();
}

class AiloitteFileImageWidgetState extends State<AiloitteFileImageWidget> {
  @override
  Widget build(BuildContext context) {
    return AiloitteImageWidget(
      image: widget.imagePath,
      fit: widget.boxFit,
      errorWidget: widget.errorWidget,
      loaderWidget: widget.loaderWidget,
      type: widget.type??AiloitteImageType.file,
      isCircular: widget.isCircular,
      imageRadius: widget.imageRadius,
      borderRadius: widget.borderRadius,
      height: widget.height,
      width: widget.width,
    );
  }
}
