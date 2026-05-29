import 'package:flutter/foundation.dart';

import '../api/api_manager.dart';
import '../extensions.dart';
import '../main.dart';

class UrlUtils {

  /// Returns the url, with the specified path appended.
  /// Supports the default connection mode, as well as the embedded mode.
  static String getUrl(String path) {
    final apiManager = getIt<ApiManager>();

    var baseUrl = apiManager.baseUrl;
    if (kIsWeb && isEmbeddedMode()) {
      final currentUri = Uri.base;
      baseUrl = "${currentUri.scheme}://${currentUri.host}";
      if (currentUri.hasPort && currentUri.port != 80 && currentUri.port != 443) {
        baseUrl += ":${currentUri.port}";
      }
    }

    // https://example.com/api/ -> https://example.com
    baseUrl = baseUrl.replaceAll(RegExp(r'(/api)?/*$'), '');

    return "$baseUrl/$path";
  }

  /// Converts a http url to a websocket url, by replacing `http://` with `ws://`
  /// and `https://` with `wss://`.
  static String httpToWs(String http) {
    // http://example.com -> ws://example.com
    // https://example.com -> wss://example.com
    return http.replaceFirst(RegExp(r'^http'), 'ws');
  }

  /// Combines `getUrl` and `httpToWs` to get the current api url with the path
  /// appended to use for websocket connections.
  static String getWsUrl(String path) {
    return httpToWs(getUrl(path));
  }
}