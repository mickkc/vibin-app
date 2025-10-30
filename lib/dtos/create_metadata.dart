import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/tags/tag.dart';

class CreateMetadata {
  final List<String> artistNames;
  final List<String> tagNames;
  final String? albumName;

  CreateMetadata({
    required this.artistNames,
    required this.tagNames,
    required this.albumName,
  });

  factory CreateMetadata.fromJson(Map<String, dynamic> json) {
    return CreateMetadata(
      artistNames: List<String>.from(json['artistNames']),
      tagNames: List<String>.from(json['tagNames']),
      albumName: json['albumName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artistNames': artistNames,
      'tagNames': tagNames,
      'albumName': albumName,
    };
  }
}

class CreateMetadataResult {
  final List<Artist> artists;
  final List<Tag> tags;
  final Album? album;

  CreateMetadataResult({
    required this.artists,
    required this.tags,
    required this.album,
  });

  factory CreateMetadataResult.fromJson(Map<String, dynamic> json) {
    return CreateMetadataResult(
      artists: (json['artists'] as List)
          .map((artistJson) => Artist.fromJson(artistJson))
          .toList(),
      tags: (json['tags'] as List)
          .map((tagJson) => Tag.fromJson(tagJson))
          .toList(),
      album: json['album'] != null ? Album.fromJson(json['album']) : null,
    );
  }
}