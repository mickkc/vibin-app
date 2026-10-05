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

  /// Returns the value of an ordered map with all missing keys set to [valueForMissing].
  /// This is used for example to set the value of keys that were added in newer versions
  /// and don't exist yet in the saved map.
  List<Entry<String, String>> getFilledMap(OrderedMapSettingsKey key, String valueForMissing) {
    var value = get(key);
    for (final entry in key.defaultValue) {
      if (!value.any((v) => v.key == entry.key)) {
        value.add(entry);
      }
    }
    return value;
  }

  void set<T>(SettingsKey<T> key, T value) {
    cache[key.key] = value;
    prefs!.setString(key.key, key.serialize(value));
  }
}