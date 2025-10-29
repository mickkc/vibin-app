import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/dtos/user/user.dart';

class PendingUpload {
  final int id;
  final String filePath;
  final String title;
  final String album;
  final List<String> artists;
  final bool explicit;
  final int? trackNumber;
  final int? trackCount;
  final int? discNumber;
  final int? discCount;
  final int? year;
  final String comment;
  final String? coverUrl;
  final User uploader;
  final List<Tag> tags;
  final String? lyrics;

  PendingUpload({
    required this.id,
    required this.filePath,
    required this.title,
    required this.album,
    required this.artists,
    required this.explicit,
    this.trackNumber,
    this.trackCount,
    this.discNumber,
    this.discCount,
    this.year,
    required this.comment,
    this.coverUrl,
    required this.uploader,
    required this.tags,
    this.lyrics,
  });

  factory PendingUpload.fromJson(Map<String, dynamic> json) {
    return PendingUpload(
      id: json['id'],
      filePath: json['filePath'],
      title: json['title'],
      album: json['album'],
      artists: List<String>.from(json['artists']),
      explicit: json['explicit'],
      trackNumber: json['trackNumber'],
      trackCount: json['trackCount'],
      discNumber: json['discNumber'],
      discCount: json['discCount'],
      year: json['year'],
      comment: json['comment'],
      coverUrl: json['coverUrl'],
      uploader: User.fromJson(json['uploader']),
      tags: (json['tags'] as List).map((tagJson) => Tag.fromJson(tagJson)).toList(),
      lyrics: json['lyrics'],
    );
  }
}