class CurrentAudioType {
  late AudioType audioType;
  late int? id;

  CurrentAudioType({
    required this.audioType,
    this.id
  });
}

enum AudioType {
  tracks,
  album,
  artist,
  playlist
}