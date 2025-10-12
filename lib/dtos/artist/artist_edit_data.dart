import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ArtistEditData {
  final String name;
  final String? description;
  final String? imageUrl;

  ArtistEditData({
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory ArtistEditData.fromJson(Map<String, dynamic> json) {
    return ArtistEditData(
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}