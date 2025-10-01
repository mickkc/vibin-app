import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AlbumEditData {
  final String? title;
  final String? coverUrl;

  AlbumEditData({
    this.title,
    this.coverUrl,
  });

  factory AlbumEditData.fromJson(Map<String, dynamic> json) {
    return AlbumEditData(
      title: json['title'] as String?,
      coverUrl: json['coverUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (coverUrl != null) 'coverUrl': coverUrl,
    };
  }
}