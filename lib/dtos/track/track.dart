import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/id_name.dart';
import 'package:vibin_app/dtos/tags/tag.dart';
import 'package:vibin_app/dtos/track/base_track.dart';

@JsonSerializable()
class Track implements BaseTrack {
  @override
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
  final String path;
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
    required this.path,
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
      path: json['path'],
      tags: (json['tags'] as List<dynamic>)
          .map((tagJson) => Tag.fromJson(tagJson))
          .toList(),
      hasLyrics: json['hasLyrics'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  String getTitle() => title;

  @override
  IdName getAlbum() => IdName(id: album.id, name: album.title);

  @override
  List<IdName> getArtists() {
    return artists.map((artist) => IdName(id: artist.id, name: artist.name)).toList();
  }

  @override
  int? getTrackNumber() => trackNumber;

  @override
  int? getDuration() => duration;
}