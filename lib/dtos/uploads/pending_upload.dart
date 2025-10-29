import 'package:vibin_app/dtos/id_or_name.dart';

class PendingUpload {
  final int id;
  final String filePath;
  final String title;
  final IdOrName album;
  final List<IdOrName> artists;
  final List<IdOrName> tags;
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
      album: json['album'],
      artists: (json['artists'] as List).map((artistJson) => IdOrName.fromJson(artistJson)).toList(),
      tags: (json['tags'] as List).map((tagJson) => IdOrName.fromJson(tagJson)).toList(),
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