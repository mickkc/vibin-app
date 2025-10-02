import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibin_app/settings/settings_key.dart';

class SettingsManager {

  Map<String, dynamic> cache = {};

  SharedPreferences? prefs;

  Future<void> ensureInitialized() async {
    prefs ??= await SharedPreferences.getInstance();
  }

  T get<T>(SettingsKey<T> key) {
    if (cache.containsKey(key.key)) {
      return cache[key.key] as T;
    }
    final value = prefs!.getString(key.key);
    if (value == null) {
      return key.defaultValue;
    }
    final parsedValue = key.parse(value);
    cache[key.key] = parsedValue;
    return parsedValue;
  }

  void set<T>(SettingsKey<T> key, T value) {
    cache[key.key] = value;
    prefs!.setString(key.key, key.serialize(value));
  }
}