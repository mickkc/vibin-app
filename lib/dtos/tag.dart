import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Tag {
  final int id;
  final String name;
  final String? color;
  final int createdAt;
  final int? updatedAt;

  Tag({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
    this.updatedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}