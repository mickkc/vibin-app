import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibin_app/dtos/login_result.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/main.dart';

import '../api/api_manager.dart';

class AuthState extends ChangeNotifier {
  bool _loggedIn = false;
  String? _accessToken;
  String? _serverAddress;
  User? _user;
  List<String> _permissions = [];

  FlutterSecureStorage prefs = const FlutterSecureStorage();

  bool get loggedIn => _loggedIn;
  String? get accessToken => _accessToken;
  String? get serverAddress => _serverAddress;
  User? get user => _user;
  List<String> get permissions => _permissions;

  Future<void> tryAutoLogin() async {

    try {
      await loadFromPrefs();
      final apiManager = getIt<ApiManager>();

      if (_serverAddress == null || _accessToken == null) {
        return;
      }

      apiManager.setBaseUrl(_serverAddress!);
      apiManager.setToken(_accessToken!);

      final validation = await apiManager.service.validateAuthorization();
      if (validation.success) {
        _loggedIn = true;
        _user = validation.user;
        _permissions = validation.permissions;
        notifyListeners();
      } else {
        await logout();
      }
    }
    catch (e) {
      await logout();
    }
  }

  Future<void> login(String serverAddress, LoginResult loginResult) async {
    _loggedIn = true;
    _serverAddress = serverAddress;
    _accessToken = loginResult.token;

    _user = loginResult.user;
    _permissions = loginResult.permissions;

    await prefs.write(key: 'serverAddress', value: serverAddress);
    await prefs.write(key: 'accessToken', value: loginResult.token);

    notifyListeners();
  }

  Future<void> logout() async {
    _loggedIn = false;
    _serverAddress = null;
    _accessToken = null;

    await prefs.delete(key: 'serverAddress');
    await prefs.delete(key: 'accessToken');

    notifyListeners();
  }

  Future<void> writeToPrefs() async {
    if (_serverAddress != null) {
      await prefs.write(key: 'serverAddress', value: _serverAddress);
    }
    if (_accessToken != null) {
      await prefs.write(key: 'accessToken', value: accessToken);
    }
  }

  Future<void> loadFromPrefs() async {
    _serverAddress = await prefs.read(key: 'serverAddress');
    _accessToken = await prefs.read(key: 'accessToken');
  }
}