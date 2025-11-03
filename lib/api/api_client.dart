import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiClient {
  final Dio dio;

  ApiClient(String baseUrl, {String? token}) : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    if (token != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $token';
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            // Centralized error logging
            log('API Error: ${e.response?.statusCode} -> ${e.message}', error: e, level: Level.error.value);
            return handler.next(e);
          },
        ),
      );
    }
  }
}
