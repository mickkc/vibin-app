import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ArtistEditData {
  final String name;
  final String? sortName;
  final String? imageUrl;
  final List<int>? tagIds;

  ArtistEditData({
    required this.name,
    this.sortName,
    this.imageUrl,
    this.tagIds,
  });

  factory ArtistEditData.fromJson(Map<String, dynamic> json) {
    return ArtistEditData(
      name: json['name'],
      sortName: json['sortName'],
      imageUrl: json['imageUrl'],
      tagIds: json['tagIds'] != null
          ? List<int>.from(json['tagIds'])
          : null,
    );
  }
}