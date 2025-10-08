import 'package:json_annotation/json_annotation.dart';

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
  final String? albumName;
  final List<String>? artistNames;
  final List<int>? tagIds;
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
    this.albumName,
    this.artistNames,
    this.tagIds,
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
      albumName: json['albumName'],
      artistNames: json['artistNames'] != null
          ? List<String>.from(json['artistNames'])
          : null,
      tagIds: json['tagIds'] != null
          ? List<int>.from(json['tagIds'])
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
      'albumName': albumName,
      'artistNames': artistNames,
      'tagIds': tagIds,
      'lyrics': lyrics,
    };
  }
}