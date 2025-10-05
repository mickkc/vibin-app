import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AlbumInfoMetadata {
  final String title;
  final String? description;
  final String? coverImageUrl;
  final String? artistName;
  final int? year;

  AlbumInfoMetadata({
    required this.title,
    this.description,
    this.coverImageUrl,
    this.artistName,
    this.year,
  });

  factory AlbumInfoMetadata.fromJson(Map<String, dynamic> json) {
    return AlbumInfoMetadata(
      title: json['title'],
      description: json['description'],
      coverImageUrl: json['coverImageUrl'],
      artistName: json['artistName'],
      year: json['year'],
    );
  }
}