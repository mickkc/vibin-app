import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';

import '../main.dart';

class NetworkImageWidget extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const NetworkImageWidget({
    super.key,
    required this.url,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = BorderRadius.zero,
  });

  bool _isAbsoluteUrl() {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  bool _isBase64Url() {
    return url.startsWith("data:image/");
  }

  String _getUrl() {
    if (_isAbsoluteUrl()) {
      return url;
    } else {
      ApiManager apiManager = getIt<ApiManager>();

      if (kIsWeb) {
        final currentUri = Uri.base;
        return "${currentUri.scheme}://${currentUri.host}:${currentUri.port}/$url";
      }

      return "${apiManager.baseUrl}/$url";
    }
  }

  Map<String, String> _getHeaders() {
    if (_isAbsoluteUrl()) {
      return {};
    }
    ApiManager apiManager = getIt<ApiManager>();
    return {
      "Authorization": "Bearer ${apiManager.accessToken}"
    };
  }

  Widget _base64Image() {
    return Image.memory(
      Uri.parse(url).data!.contentAsBytes(),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: const Center(child: Icon(Icons.error)),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: _isBase64Url() ? _base64Image() : Image.network(
          _getUrl(),
          width: width,
          height: height,
          fit: fit,
          headers: _getHeaders(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: width,
              height: height,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: width,
              height: height,
              child: const Center(child: Icon(Icons.error)),
            );
          },
        )
      ),
    );
  }
}