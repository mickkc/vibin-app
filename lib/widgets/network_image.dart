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

  bool isAbsoluteUrl() {
    return url.startsWith("http://") || url.startsWith("https://");
  }

  String getUrl() {
    if (isAbsoluteUrl()) {
      return url;
    } else {
      ApiManager apiManager = getIt<ApiManager>();
      return "${apiManager.baseUrl}/$url";
    }
  }

  Map<String, String> getHeaders() {
    if (isAbsoluteUrl()) {
      return {};
    }
    ApiManager apiManager = getIt<ApiManager>();
    return {
      "Authorization": "Bearer ${apiManager.accessToken}"
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          getUrl(),
          width: width,
          height: height,
          fit: fit,
          headers: getHeaders(),
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