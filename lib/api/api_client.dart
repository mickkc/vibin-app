import 'package:dio/dio.dart';

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
            print('API Error: ${e.response?.statusCode} -> ${e.message}');
            return handler.next(e);
          },
        ),
      );
    }
  }
}
