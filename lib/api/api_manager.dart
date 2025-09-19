import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vibin_app/api/rest_api.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();

  late String _accessToken;
  String get accessToken => _accessToken;

  late Dio dio;
  late ApiService service;

  factory ApiManager() => _instance;

  ApiManager._internal() {
    dio = Dio();
  }

  String get baseUrl => dio.options.baseUrl;

  void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
    service = ApiService(dio, baseUrl: baseUrl);
  }

  void setToken(String token) {
    _accessToken = token;
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  Future<void> checkConnection() async {
    final response = await service.checkServer();
    final serverVersion = response.version;

    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    if (serverVersion != appVersion) {
      throw Exception('Version mismatch: Server version $serverVersion, App version $appVersion');
    }

    if (response.status != 'ok') {
      throw Exception('Server status not OK: ${response.status}');
    }
  }
}
