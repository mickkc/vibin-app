import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/image.dart';
import 'package:vibin_app/dtos/tags/tag.dart';

@JsonSerializable()
class Track {
  final int id;
  final String title;
  final Album album;
  final List<Artist> artists;
  final bool explicit;
  final int? trackNumber;
  final int? trackCount;
  final int? discNumber;
  final int? discCount;
  final int? year;
  final int? duration;
  final String? comment;
  final int? bitrate;
  final int? sampleRate;
  final int? channels;
  final Image? cover;
  final String path;
  final String checksum;
  final List<Tag> tags;
  final bool hasLyrics;
  final int createdAt;
  final int? updatedAt;

  Track({
    required this.id,
    required this.title,
    required this.album,
    required this.artists,
    required this.explicit,
    this.trackNumber,
    this.trackCount,
    this.discNumber,
    this.discCount,
    this.year,
    this.duration,
    this.comment,
    this.bitrate,
    this.sampleRate,
    this.channels,
    this.cover,
    required this.path,
    required this.checksum,
    required this.tags,
    required this.hasLyrics,
    required this.createdAt,
    this.updatedAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
      album: Album.fromJson(json['album']),
      artists: (json['artists'] as List<dynamic>)
          .map((artistJson) => Artist.fromJson(artistJson))
          .toList(),
      explicit: json['explicit'],
      trackNumber: json['trackNumber'],
      trackCount: json['trackCount'],
      discNumber: json['discNumber'],
      discCount: json['discCount'],
      year: json['year'],
      duration: json['duration'],
      comment: json['comment'],
      bitrate: json['bitrate'],
      sampleRate: json['sampleRate'],
      channels: json['channels'],
      cover: json['cover'] != null ? Image.fromJson(json['cover']) : null,
      path: json['path'],
      checksum: json['checksum'],
      tags: (json['tags'] as List<dynamic>)
          .map((tagJson) => Tag.fromJson(tagJson))
          .toList(),
      hasLyrics: json['hasLyrics'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}