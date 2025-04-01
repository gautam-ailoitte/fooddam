import 'dart:developer' as dev;
import 'dart:io';

import 'package:ailoitte_components/src/custom_widgets/image/core/type.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_network/image_network.dart' as ImageFromNetwork;

class AiloitteImageWidget extends StatefulWidget {
  const AiloitteImageWidget({
    Key? key,
    required this.image,
    this.isCircular = false,
    this.borderRadius = 0,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.errorWidget,
    this.loaderWidget,
    this.imageRadius = 48,
    required this.type,
    this.webFit,
  }) : /* assert(image.isNotEmpty,"Url Host not specified"),*/ super(key: key);

  final String image;
  final bool isCircular;
  final double borderRadius;
  final double imageRadius;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? loaderWidget;
  final AiloitteImageType type;
  final ImageFromNetwork.BoxFitWeb? webFit;

  @override
  AiloitteImageWidgetState createState() => AiloitteImageWidgetState();
}

class AiloitteImageWidgetState extends State<AiloitteImageWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.isCircular
        ? ClipOval(
            child: SizedBox.fromSize(
              size: Size.fromRadius(widget.imageRadius),
              child: _getSelectedImage(),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: _getSelectedImage(),
            ),
          );
  }

  Widget _getSelectedImage() {
    if (widget.type == AiloitteImageType.network) {
      /// Todo : Authenticate URL for
      /// because of this condition errorwidget will never work
      return (widget.image).isNotEmpty
          ? kIsWeb
              ? ImageFromNetwork.ImageNetwork(
                  image: widget.image,
                  fitWeb: widget.webFit ?? ImageFromNetwork.BoxFitWeb.cover,
                  height: widget.height ?? 100,
                  width: widget.width ?? 100,
                )
              : CachedNetworkImage(
                  imageUrl: widget.image,
                  fit: widget.fit ?? BoxFit.fill,
                  errorWidget: (context, url, error) {
                    dev.log('GET IMAGE ERROR\nInvalid URL');
                    return widget.errorWidget ??
                        SizedBox(
                          child: SvgPicture.asset('assets/placeholder.svg'),
                        );
                  },
                  placeholder: (context, url) {
                    return widget.loaderWidget ?? Container();
                  },
                )
          : kIsWeb
              ? ImageFromNetwork.ImageNetwork(
                  image: widget.image,
                  fitWeb: widget.webFit ?? ImageFromNetwork.BoxFitWeb.cover,
                  height: widget.height ?? 100,
                  width: widget.width ?? 100,
                )
              : CachedNetworkImage(
                  imageUrl: widget.image,
                  fit: widget.fit ?? BoxFit.fill,
                  errorWidget: (context, url, error) {
                    dev.log('GET IMAGE ERROR\nInvalid URL');
                    return widget.errorWidget ?? Container();
                  },
                  placeholder: (context, url) {
                    return widget.loaderWidget ?? Container();
                  },
                );
    } else if (widget.type == AiloitteImageType.file) {
      return Image.file(
        File(widget.image),
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ??
              SizedBox(
                height: widget.height,
                width: widget.width,
                child: const Center(
                  child: Text(
                    'GET IMAGE ERROR\nInvalid File Path',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
        },
        fit: widget.fit ?? BoxFit.fill,
      );
    }
    return _isSvg()
        ? SvgPicture.asset(
            widget.image,
            fit: widget.fit ?? BoxFit.none,
            color: widget.color,
          )
        : Image.asset(
            widget.image,
            color: widget.color,
            fit: widget.fit ?? BoxFit.none,
          );
  }

  bool _isSvg() {
    // log("${widget.image}", name: "svg");
    bool isSvg = widget.image.toLowerCase().endsWith(".svg");
    // log("${isSvg}", name: "svg");
    return isSvg;
    // return widget.image
    //             .substring(widget.image.length - 4, widget.image.length) ==
    //         '.svg' ||
    //     widget.image.substring(widget.image.length - 4, widget.image.length) ==
    //         '.SVG';
  }
}
