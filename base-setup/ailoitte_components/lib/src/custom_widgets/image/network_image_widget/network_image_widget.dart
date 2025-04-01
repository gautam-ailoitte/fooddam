import 'package:ailoitte_components/src/custom_widgets/image/core/type.dart';
import 'package:ailoitte_components/src/custom_widgets/image/core/widget.dart';
import 'package:flutter/material.dart';

class AiloitteNetworkImageWidget extends StatefulWidget {
  const AiloitteNetworkImageWidget({
    Key? key,
    required this.imageUrl,
    this.boxFit,
    this.errorWidget,
    this.loaderWidget,
    this.isCircular = false,
    this.borderRadius = 0,
    this.height,
    this.width,
    this.imageRadius = 48,
  }) : super(key: key);

  final String imageUrl;
  final BoxFit? boxFit;
  final Widget? errorWidget;
  final Widget? loaderWidget;
  final bool isCircular;
  final double borderRadius;
  final double imageRadius;
  final double? height;
  final double? width;

  @override
  AiloitteNetworkImageWidgetState createState() =>
      AiloitteNetworkImageWidgetState();
}

class AiloitteNetworkImageWidgetState
    extends State<AiloitteNetworkImageWidget> {
  @override
  Widget build(BuildContext context) {
    return AiloitteImageWidget(
      image: widget.imageUrl,
      fit: widget.boxFit,
      errorWidget: widget.errorWidget,
      loaderWidget: widget.loaderWidget,
      type: AiloitteImageType.network,
      isCircular: widget.isCircular,
      imageRadius: widget.imageRadius,
      borderRadius: widget.borderRadius,
      height: widget.height,
      width: widget.width,
    );
  }
}
