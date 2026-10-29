import 'package:vibin_app/dtos/settings/setting.dart';

class SettingsMap {
  final Map<String, Setting> settings;

  SettingsMap({required this.settings});

  factory SettingsMap.fromJson(Map<String, dynamic> json) {
    return SettingsMap(settings: json.map((k,v) => MapEntry(k, Setting.fromJson(v))));
  }
}