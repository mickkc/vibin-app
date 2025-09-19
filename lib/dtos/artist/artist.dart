import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/image.dart';
import 'package:vibin_app/dtos/tag.dart';

@JsonSerializable()
class Artist {
  final int id;
  final String name;
  final Image? image;
  final String? sortName;
  final List<Tag> tags;
  final int createdAt;
  final int? updatedAt;

  Artist({
    required this.id,
    required this.name,
    this.image,
    this.sortName,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      image: json['image'] != null ? Image.fromJson(json['image']) : null,
      sortName: json['sortName'],
      tags: (json['tags'] as List<dynamic>)
          .map((tagJson) => Tag.fromJson(tagJson))
          .toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}