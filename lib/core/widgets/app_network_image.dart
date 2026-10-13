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
  if (isTest || (kIsWeb && url.startsWith('blob:'))) {
    return NetworkImage(url);
  }
  return CachedNetworkImageProvider(url);
}

/// A universal, cross-platform image component that gracefully handles:
/// - Remote URLs (http/https via [CachedNetworkImage])
/// - Web Blob URLs (blob: via [Image.network])
/// - Local File system paths on mobile/desktop (via [Image.file])
/// - Asset paths (assets/ via [Image.asset])
class AppImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return _buildFallback(context);
    }

    // 1. Web Blob URL
    if (imagePath.startsWith('blob:')) {
      return Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    }

    // 2. HTTP/HTTPS Network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return AppNetworkImage(
        imageUrl: imagePath,
        height: height,
        width: width,
        fit: fit,
        placeholder: placeholder != null ? (_, _) => placeholder! : null,
        errorWidget: errorWidget != null ? (_, _, _) => errorWidget! : null,
      );
    }

    // 3. Local Flutter Asset
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    }

    // 4. Flutter Web: local File is unsupported, fallback to Image.network
    if (kIsWeb) {
      return Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    }

    // 5. Mobile & Desktop local File
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        );
      }
    } catch (_) {
      // Fallback if File constructor or existsSync throws
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    if (errorWidget != null) return errorWidget!;
    return Container(
      height: height,
      width: width,
      color: Colors.white.withValues(alpha: 0.05),
      child: const Icon(Icons.broken_image_outlined, color: Colors.white54),
    );
  }
}
