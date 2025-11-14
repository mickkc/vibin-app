import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class TagEditData {
  final String name;
  final String? description;
  final int importance;

  TagEditData({required this.name, this.description, required this.importance});

  factory TagEditData.fromJson(Map<String, dynamic> json) {
    return TagEditData(
      name: json['name'],
      description: json['description'],
      importance: json['importance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'importance': importance,
    };
  }
}