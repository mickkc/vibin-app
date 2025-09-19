import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/artist/artist.dart';

@JsonSerializable()
class ArtistPagination {

  final List<Artist> items;
  final int total;
  final int pageSize;
  final int currentPage;

  ArtistPagination({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory ArtistPagination.fromJson(Map<String, dynamic> json) {
    return ArtistPagination(
      items: (json['items'] as List<dynamic>)
          .map((albumJson) => Artist.fromJson(albumJson))
          .toList(),
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      total: json['total'],
    );
  }
}