import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: errorWidget != null
            ? (context, error, stackTrace) => errorWidget!(context, imageUrl, error)
            : null,
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

ImageProvider getAppImageProvider(String url) {
  final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
  if (isTest) {
    return NetworkImage(url);
  }
  return CachedNetworkImageProvider(url);
}
