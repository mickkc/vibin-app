class Setting {
  final String key;
  dynamic value;
  final String? validationRegex;

  Setting({
    required this.key,
    required this.value,
    this.validationRegex
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      key: json['key'],
      value: json['value'],
      validationRegex: json['validationRegex']
    );
  }
}