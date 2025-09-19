import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/album/album.dart';

@JsonSerializable()
class AlbumPagination {

  final List<Album> items;
  final int total;
  final int pageSize;
  final int currentPage;

  AlbumPagination({
    required this.items,
    required this.total,
    required this.pageSize,
    required this.currentPage,
  });

  factory AlbumPagination.fromJson(Map<String, dynamic> json) {
    return AlbumPagination(
      items: (json['items'] as List<dynamic>)
          .map((albumJson) => Album.fromJson(albumJson))
          .toList(),
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      total: json['total'],
    );
  }
}