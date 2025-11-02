class SettingsMap {
  final Map<String, dynamic> settings;

  SettingsMap({required this.settings});

  factory SettingsMap.fromJson(Map<String, dynamic> json) {
    return SettingsMap(settings: json);
  }
}