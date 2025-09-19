import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';

@JsonSerializable()
class MinimalTrackPagination {

  final List<MinimalTrack> items;
  final int total;
  final int pageSize;
  final int currentPage;

  MinimalTrackPagination({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory MinimalTrackPagination.fromJson(Map<String, dynamic> json) {
    return MinimalTrackPagination(
      items: (json['items'] as List<dynamic>)
          .map((albumJson) => MinimalTrack.fromJson(albumJson))
          .toList(),
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      total: json['total'],
    );
  }
}