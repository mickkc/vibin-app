import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/tags/tag.dart';

class PendingUpload {
  final String id;
  final String filePath;
  final String title;
  final Album? album;
  final List<Artist> artists;
  final List<Tag> tags;
  final String? lyrics;
  final bool explicit;
  final int? trackNumber;
  final int? trackCount;
  final int? discNumber;
  final int? discCount;
  final int? year;
  final String comment;
  final String? coverUrl;
  final int uploaderId;
  final int? lastUpdated;

  PendingUpload({
    required this.id,
    required this.filePath,
    required this.title,
    required this.album,
    required this.artists,
    this.lyrics,
    required this.explicit,
    this.trackNumber,
    this.trackCount,
    this.discNumber,
    this.discCount,
    this.year,
    required this.comment,
    this.coverUrl,
    required this.uploaderId,
    required this.tags,
    this.lastUpdated,
  });

  factory PendingUpload.fromJson(Map<String, dynamic> json) {
    return PendingUpload(
      id: json['id'],
      filePath: json['filePath'],
      title: json['title'],
      album: json['album'] != null ? Album.fromJson(json['album']) : null,
      artists: (json['artists'] as List)
          .map((artistJson) => Artist.fromJson(artistJson))
          .toList(),
      tags: (json['tags'] as List)
          .map((tagJson) => Tag.fromJson(tagJson))
          .toList(),
      explicit: json['explicit'],
      trackNumber: json['trackNumber'],
      trackCount: json['trackCount'],
      discNumber: json['discNumber'],
      discCount: json['discCount'],
      year: json['year'],
      comment: json['comment'],
      lyrics: json['lyrics'],
      coverUrl: json['coverUrl'],
      uploaderId: json['uploaderId'],
      lastUpdated: json['lastUpdated'],
    );
  }
}