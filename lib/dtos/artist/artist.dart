import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Artist {
  final int id;
  final String name;
  final String description;
  final int createdAt;
  final int? updatedAt;

  Artist({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}