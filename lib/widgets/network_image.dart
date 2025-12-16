import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/extensions.dart';

import '../main.dart';

class NetworkImageWidget extends StatefulWidget {
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

  @override
  State<NetworkImageWidget> createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<NetworkImageWidget> {

  bool _isAbsoluteUrl() {
    return widget.url.startsWith("http://") || widget.url.startsWith("https://");
  }

  bool _isBase64Url() {
    return widget.url.startsWith("data:image/");
  }

  String _getUrl() {
    if (_isAbsoluteUrl()) {
      return widget.url;
    } else {
      ApiManager apiManager = getIt<ApiManager>();

      if (kIsWeb && isEmbeddedMode()) {
        final currentUri = Uri.base;
        return "${currentUri.scheme}://${currentUri.host}:${currentUri.port}/${widget.url}";
      }

      return "${apiManager.baseUrl}/${widget.url}";
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

  late final String? _url;
  late final Uint8List? _base64Data;
  late final Map<String, String> _headers;

  @override
  void initState() {
    super.initState();
    _url = _isBase64Url() ? null : _getUrl();
    _base64Data = _isBase64Url() ? Uri.parse(widget.url).data!.contentAsBytes() : null;
    _headers = _getHeaders();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: _base64Data != null
          ? Image.memory(
              _base64Data,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: const Center(child: Icon(Icons.error)),
                );
              }
            )
          : Image.network(
              _url!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              headers: _headers,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: widget.width,
                  height: widget.height,
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
                  width: widget.width,
                  height: widget.height,
                  child: const Center(child: Icon(Icons.error)),
                );
              },
            )
      ),
    );
  }
}