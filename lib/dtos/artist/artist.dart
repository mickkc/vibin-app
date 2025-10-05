import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/image.dart';

@JsonSerializable()
class Artist {
  final int id;
  final String name;
  final String description;
  final Image? image;
  final int createdAt;
  final int? updatedAt;

  Artist({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.createdAt,
    this.updatedAt,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'] != null ? Image.fromJson(json['image']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}