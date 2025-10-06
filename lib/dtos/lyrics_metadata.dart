class LyricsMetadata {
  final String title;
  final String? artistName;
  final String? albumName;
  final String content;
  final bool synced;
  final int? duration;

  LyricsMetadata({
    required this.title,
    this.artistName,
    this.albumName,
    required this.content,
    required this.synced,
    this.duration,
  });

  factory LyricsMetadata.fromJson(Map<String, dynamic> json) {
    return LyricsMetadata(
      title: json['title'],
      artistName: json['artistName'],
      albumName: json['albumName'],
      content: json['content'],
      synced: json['synced'],
      duration: json['duration'],
    );
  }
}