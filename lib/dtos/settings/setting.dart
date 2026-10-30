class Setting {
  final String key;
  dynamic value;
  final String? validationRegex;

  late final RegExp? _validationPattern = validationRegex == null ? null : RegExp(validationRegex!);

  Setting({
    required this.key,
    required this.value,
    this.validationRegex
  });

  bool isValid(String input) {
    return _validationPattern?.hasMatch(input) ?? true;
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      key: json['key'],
      value: json['value'],
      validationRegex: json['validationRegex']
    );
  }
}