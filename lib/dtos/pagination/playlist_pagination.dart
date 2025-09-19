import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';

@JsonSerializable()
class PlaylistPagination {

  final List<Playlist> items;
  final int total;
  final int pageSize;
  final int currentPage;

  PlaylistPagination({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory PlaylistPagination.fromJson(Map<String, dynamic> json) {
    return PlaylistPagination(
      items: (json['items'] as List<dynamic>)
          .map((albumJson) => Playlist.fromJson(albumJson))
          .toList(),
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      total: json['total'],
    );
  }
}