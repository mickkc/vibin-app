import 'package:vibin_app/dtos/artist/artist.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';

class UserActivity {
  final List<MinimalTrack> recentTracks;
  final List<MinimalTrack> topTracks;
  final List<Artist> topArtists;

  UserActivity({
    required this.recentTracks,
    required this.topTracks,
    required this.topArtists,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      recentTracks: (json['recentTracks'] as List<dynamic>)
          .map((e) => MinimalTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
      topTracks: (json['topTracks'] as List<dynamic>)
          .map((e) => MinimalTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
      topArtists: (json['topArtists'] as List<dynamic>)
          .map((e) => Artist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}