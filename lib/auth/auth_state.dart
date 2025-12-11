import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibin_app/auth/auto_login_result.dart';
import 'package:vibin_app/dtos/login_result.dart';
import 'package:vibin_app/dtos/permission_type.dart';
import 'package:vibin_app/dtos/user/user.dart';
import 'package:vibin_app/main.dart';

import '../api/api_manager.dart';
import '../audio/audio_manager.dart';

class AuthState extends ChangeNotifier {
  bool _loggedIn = false;
  String? _accessToken;
  String? _serverAddress;
  User? _user;
  List<String> _permissions = [];
  AutoLoginResult? autoLoginResult;

  FlutterSecureStorage prefs = const FlutterSecureStorage();

  bool get loggedIn => _loggedIn;
  String? get accessToken => _accessToken;
  String? get serverAddress => _serverAddress;
  User? get user => _user;
  List<String> get permissions => _permissions;

  Future<AutoLoginResult> tryAutoLogin() async {

    try {
      await loadFromPrefs();
      final apiManager = getIt<ApiManager>();

      if (_serverAddress == null || _accessToken == null) {
        return AutoLoginResult(false, null, false);
      }

      apiManager.setBaseUrl(_serverAddress!);
      apiManager.setToken(_accessToken!);

      await apiManager.checkConnection();

      final validation = await apiManager.service.validateAuthorization();
      if (validation.success) {
        _loggedIn = true;
        _user = validation.user;
        _permissions = validation.permissions;
        notifyListeners();
        return AutoLoginResult.success;
      } else {
        return AutoLoginResult(false, Exception("Token validation failed"), false);
      }
    }
    catch (e) {
      return AutoLoginResult(false, e, true);
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

    final audioManager = getIt<AudioManager>();
    audioManager.init();

    notifyListeners();
  }

  Future<void> logout() async {
    final audioManager = getIt<AudioManager>();
    await audioManager.cleanup();

    _loggedIn = false;
    _serverAddress = null;
    _accessToken = null;
    autoLoginResult = null;
    _user = null;
    _permissions = [];

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

  void clearAutoLoginResult() {
    autoLoginResult = null;
    notifyListeners();
  }


  bool hasPermission(PermissionType permission) {
    if (user != null && user!.isAdmin) {
      return true;
    }
    return _permissions.contains(permission.value);
  }

  bool hasAnyPermission(List<PermissionType> permissions) {
    for (final permission in permissions) {
      if (hasPermission(permission)) {
        return true;
      }
    }
    return false;
  }

  bool hasPermissions(List<PermissionType> permissions) {
    for (final permission in permissions) {
      if (!hasPermission(permission)) {
        return false;
      }
    }
    return true;
  }
}