class Streamable {
  final int trackId;
  final String title;
  final String artist;
  final String album;
  final int? duration;
  final double? volumeOffset;
  final String? coverChecksum;
  final String? coverSignature;
  final int? coverExpiration;
  final String streamSignature;
  final int streamExpiration;

  Streamable({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.album,
    this.duration,
    this.volumeOffset,
    this.coverChecksum,
    this.coverSignature,
    this.coverExpiration,
    required this.streamSignature,
    required this.streamExpiration,
  });

  factory Streamable.fromJson(Map<String, dynamic> json) {
    return Streamable(
      trackId: json['trackId'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      duration: json['duration'],
      volumeOffset: json['volumeOffset'] != null ? (json['volumeOffset'] as num).toDouble() : null,
      coverChecksum: json['coverChecksum'],
      coverSignature: json['coverSignature'],
      coverExpiration: json['coverExpiration'],
      streamSignature: json['streamSignature'],
      streamExpiration: json['streamExpiration'],
    );
  }
}