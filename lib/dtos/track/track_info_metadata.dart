import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class TrackInfoMetadata {
  final String title;
  final List<String>? artistNames;
  final String? albumName;
  final int? trackNumber;
  final int? trackCount;
  final int? discNumber;
  final int? discCount;
  final int? year;
  final List<String>? tags;
  final String? comment;
  final String? coverImageUrl;
  final bool? explicit;

  TrackInfoMetadata({
    required this.title,
    this.artistNames,
    this.albumName,
    this.trackNumber,
    this.trackCount,
    this.discNumber,
    this.discCount,
    this.year,
    this.tags,
    this.comment,
    this.coverImageUrl,
    this.explicit,
  });

  factory TrackInfoMetadata.fromJson(Map<String, dynamic> json) {
    return TrackInfoMetadata(
      title: json['title'],
      artistNames: json['artistNames'] != null
          ? List<String>.from(json['artistNames'])
          : null,
      albumName: json['albumName'],
      trackNumber: json['trackNumber'],
      trackCount: json['trackCount'],
      discNumber: json['discNumber'],
      discCount: json['discCount'],
      year: json['year'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      comment: json['comment'],
      coverImageUrl: json['coverImageUrl'],
      explicit: json['explicit'],
    );
  }
}