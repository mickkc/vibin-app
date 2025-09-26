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
  final int? albumId;
  final List<int>? artistIds;
  final List<int>? tagIds;

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
    this.albumId,
    this.artistIds,
    this.tagIds,
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
      albumId: json['albumId'],
      artistIds: json['artistIds'] != null
          ? List<int>.from(json['artistIds'])
          : null,
      tagIds: json['tagIds'] != null
          ? List<int>.from(json['tagIds'])
          : null,
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
      'albumId': albumId,
      'artistIds': artistIds,
      'tagIds': tagIds,
    };
  }
}