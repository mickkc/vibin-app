import 'dart:developer';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibin_app/extensions.dart';

import '../main.dart';
import 'api_manager.dart';

class ClientData {
  final String deviceId;
  String? mediaToken;

  final sharedPrefsFuture = SharedPreferences.getInstance();

  ClientData({
    required this.deviceId,
    this.mediaToken,
  });

  static Future<ClientData> loadOrRandom() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final deviceId = sharedPrefs.getString('deviceId');

    if (deviceId != null) {
      return ClientData(deviceId: deviceId);
    } else {
      final newClientData = ClientData(deviceId: randomString(8));
      await sharedPrefs.setString('deviceId', newClientData.deviceId);
      return newClientData;
    }
  }

  Future<String> getMediaToken() async {
    if (mediaToken != null) {
      return mediaToken!;
    }

    try {
      final sharedPrefs = await sharedPrefsFuture;
      final storedToken = sharedPrefs.getString('mediaToken');
      if (await _validateMediaToken(storedToken)) {
        mediaToken = storedToken;
        return mediaToken!;
      }
    }
    catch (e) {
      log("Failed to validate stored media token: $e", error: e, level: Level.error.value);
    }

    try {
      final apiManager = getIt<ApiManager>();
      final tokenResponse = await apiManager.service.createMediaToken(deviceId);

      mediaToken = tokenResponse.mediaToken;
      final sharedPrefs = await sharedPrefsFuture;
      await sharedPrefs.setString('mediaToken', mediaToken!);

      return mediaToken!;
    }
    catch (e) {
      log("Failed to get media token: $e", error: e, level: Level.error.value);
      return "";
    }
  }

  static Future<bool> _validateMediaToken(String? token) async {
    if (token == null) {
      return false;
    }

    try {
      final apiManager = getIt<ApiManager>();
      final validation = await apiManager.service.checkMediaToken(token);
      return validation.success;
    }
    catch (e) {
      log("Failed to validate media token: $e", error: e, level: Level.error.value);
      return false;
    }
  }
}