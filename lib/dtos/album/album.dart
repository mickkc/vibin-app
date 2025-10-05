import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/image.dart';

@JsonSerializable()
class Album {
  final int id;
  final String title;
  final String description;
  final int? year;
  final List<Artist> artists;
  final Image? cover;
  final int trackCount;
  final int createdAt;
  final int? updatedAt;

  Album({
    required this.id,
    required this.title,
    required this.artists,
    this.cover,
    required this.trackCount,
    required this.createdAt,
    this.updatedAt,
    required this.description,
    this.year,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      year: json['year'],
      artists: (json['artists'] as List<dynamic>)
          .map((artistJson) => Artist.fromJson(artistJson))
          .toList(),
      cover: json['cover'] != null ? Image.fromJson(json['cover']) : null,
      trackCount: json['trackCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}