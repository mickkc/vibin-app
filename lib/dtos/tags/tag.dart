import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Tag {
  final int id;
  final String name;
  final String description;
  final int importance;
  final int createdAt;
  final int? updatedAt;

  Tag({
    required this.id,
    required this.name,
    required this.description,
    required this.importance,
    required this.createdAt,
    this.updatedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      importance: json['importance'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}