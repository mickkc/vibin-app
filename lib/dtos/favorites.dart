import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';

class Favorites {
  final List<MinimalTrack?> tracks;
  final List<Artist?> artists;
  final List<Album?> albums;

  Favorites({
    required this.tracks,
    required this.artists,
    required this.albums,
  });

  factory Favorites.fromJson(Map<String, dynamic> json) {
    return Favorites(
      tracks: (json['tracks'] as List<dynamic>).map((e) => e != null ? MinimalTrack.fromJson(e) : null).toList(),
      artists: (json['artists'] as List<dynamic>).map((e) => e != null ? Artist.fromJson(e) : null).toList(),
      albums: (json['albums'] as List<dynamic>).map((e) => e != null ? Album.fromJson(e) : null).toList(),
    );
  }
}