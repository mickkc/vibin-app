class IdOrName {
  final int? id;
  final String name;
  final bool fallbackName;

  IdOrName({
    this.id,
    required this.name,
    this.fallbackName = false,
  });

  factory IdOrName.fromJson(Map<String, dynamic> json) {
    return IdOrName(
      id: json['id'],
      name: json['name'],
      fallbackName: json['fallbackName'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fallbackName': fallbackName,
    };
  }
}