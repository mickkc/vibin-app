class GlobalStats {
  final int totalTracks;
  final int totalTrackDuration;
  final int totalArtists;
  final int totalAlbums;
  final int totalPlaylists;
  final int totalUsers;
  final int totalPlays;
  final int totalListenDuration;

  GlobalStats({
    required this.totalTracks,
    required this.totalTrackDuration,
    required this.totalArtists,
    required this.totalAlbums,
    required this.totalPlaylists,
    required this.totalUsers,
    required this.totalPlays,
    required this.totalListenDuration
  });

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      totalTracks: json['totalTracks'],
      totalTrackDuration: json['totalTrackDuration'],
      totalArtists: json['totalArtists'],
      totalAlbums: json['totalAlbums'],
      totalPlaylists: json['totalPlaylists'],
      totalUsers: json['totalUsers'],
      totalPlays: json['totalPlays'],
      totalListenDuration: json['totalListenDuration']
    );
  }
}