import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class PlaylistEditData {
  final String name;
  final String? description;
  final bool? isPublic;
  final String? coverImageUrl;
  final List<int>? collaboratorIds;
  final String? vibedef;

  PlaylistEditData({
    required this.name,
    this.description,
    this.isPublic,
    this.coverImageUrl,
    this.collaboratorIds,
    this.vibedef,
  });

  factory PlaylistEditData.fromJson(Map<String, dynamic> json) {
    return PlaylistEditData(
      name: json['name'],
      description: json['description'],
      isPublic: json['isPublic'],
      coverImageUrl: json['coverImageUrl'],
      collaboratorIds: json['collaboratorIds'] != null
          ? List<int>.from(json['collaboratorIds'])
          : null,
      vibedef: json['vibedef'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'coverImageUrl': coverImageUrl,
      'collaboratorIds': collaboratorIds,
      'vibedef': vibedef,
    };
  }
}