import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AlbumEditData {
  final String? title;
  final String? description;
  final int? year;
  final String? coverUrl;

  AlbumEditData({
    this.title,
    this.coverUrl,
    this.description,
    this.year,
  });

  factory AlbumEditData.fromJson(Map<String, dynamic> json) {
    return AlbumEditData(
      title: json['title'] as String?,
      coverUrl: json['coverUrl'] as String?,
      description: json['description'] as String?,
      year: json['year'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'coverUrl': coverUrl,
      'description': description,
      'year': year,
    };
  }
}