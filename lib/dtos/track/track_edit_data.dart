import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/id_or_name.dart';

@JsonSerializable()
class TrackEditData {
  final String? title;
  final bool? explicit;
  final int? trackNumber;
  final int? trackCount;
  final int? discNumber;
  final int? discCount;
  final int? year;
  final String? comment;
  final String? imageUrl;
  final IdOrName? album;
  final List<IdOrName>? artists;
  final List<IdOrName>? tags;
  final String? lyrics;

  TrackEditData({
    this.title,
    this.explicit,
    this.trackNumber,
    this.trackCount,
    this.discNumber,
    this.discCount,
    this.year,
    this.comment,
    this.imageUrl,
    this.album,
    this.artists,
    this.tags,
    this.lyrics,
  });

  factory TrackEditData.fromJson(Map<String, dynamic> json) {
    return TrackEditData(
      title: json['title'],
      explicit: json['explicit'],
      trackNumber: json['trackNumber'],
      trackCount: json['trackCount'],
      discNumber: json['discNumber'],
      discCount: json['discCount'],
      year: json['year'],
      comment: json['comment'],
      imageUrl: json['imageUrl'],
      album: json['album'] != null
          ? IdOrName.fromJson(json['album'])
          : null,
      artists: json['artists'] != null
          ? List<IdOrName>.from(json['artists'])
          : null,
      tags: json['tags'] != null
          ? List<IdOrName>.from(json['tags'])
          : null,
      lyrics: json['lyrics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'explicit': explicit,
      'trackNumber': trackNumber,
      'trackCount': trackCount,
      'discNumber': discNumber,
      'discCount': discCount,
      'year': year,
      'comment': comment,
      'imageUrl': imageUrl,
      'album': album,
      'artists': artists,
      'tags': tags,
      'lyrics': lyrics,
    };
  }
}