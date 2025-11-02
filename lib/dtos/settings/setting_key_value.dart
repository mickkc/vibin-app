class SettingKeyValue {
  final String key;
  final dynamic value;

  SettingKeyValue({
    required this.key,
    required this.value,
  });

  factory SettingKeyValue.fromJson(Map<String, dynamic> json) {
    return SettingKeyValue(
      key: json['key'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}