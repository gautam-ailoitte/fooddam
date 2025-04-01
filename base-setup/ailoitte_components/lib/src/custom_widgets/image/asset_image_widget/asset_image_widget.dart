import 'package:ailoitte_components/src/custom_widgets/image/core/type.dart';
import 'package:ailoitte_components/src/custom_widgets/image/core/widget.dart';
import 'package:flutter/material.dart';

class AilAssetImageWidget extends StatefulWidget {
  const AilAssetImageWidget({
    Key? key,
    required this.path,
    this.isCircular = false,
    this.borderRadius = 0,
    this.height,
    this.width,
    this.color,
    this.boxFit,
    this.errorWidget,
    this.loaderWidget,
    this.imageRadius = 48,
  }) : super(key: key);

  final String path;
  final BoxFit? boxFit;
  final Widget? errorWidget;
  final Widget? loaderWidget;
  final bool isCircular;
  final double borderRadius;
  final double imageRadius;
  final double? height;
  final double? width;
  final Color? color;

  @override
  AilAssetImageWidgetState createState() =>
      AilAssetImageWidgetState();
}

class AilAssetImageWidgetState extends State<AilAssetImageWidget> {
  @override
  Widget build(BuildContext context) {
    return AiloitteImageWidget(
      image: widget.path,
      fit: widget.boxFit,
      errorWidget: widget.errorWidget,
      loaderWidget: widget.loaderWidget,
      type: AiloitteImageType.asset,
      isCircular: widget.isCircular,
      imageRadius: widget.imageRadius,
      borderRadius: widget.borderRadius,
      height: widget.height,
      width: widget.width,
      color: widget.color,
    );
  }
}
