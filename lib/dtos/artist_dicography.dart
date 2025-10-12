import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';

class ArtistDiscography {
  final Album key;
  final List<MinimalTrack> value;

  ArtistDiscography(this.key, this.value);

  factory ArtistDiscography.fromJson(Map<String, dynamic> json) {
    return ArtistDiscography(
      Album.fromJson(json['key']),
      (json['value'] as List).map((e) => MinimalTrack.fromJson(e)).toList(),
    );
  }
}