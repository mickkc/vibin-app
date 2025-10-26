import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/api/client_data.dart';
import 'package:vibin_app/audio/audio_type.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/album/album_data.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/playlist/playlist_data.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';
import 'package:vibin_app/dtos/track/track.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/settings/setting_definitions.dart';

import '../settings/settings_manager.dart';

class AudioManager extends BaseAudioHandler with QueueHandler, SeekHandler {

  late final ApiManager _apiManager;
  late final AudioPlayer audioPlayer;
  late final ClientData _clientData;

  CurrentAudioType? _currentAudioType;
  CurrentAudioType? get currentAudioType => _currentAudioType;

  void setAudioType(AudioType type, int? id) {
    _currentAudioType = CurrentAudioType(audioType: type, id: id);
  }

  AudioManager() {
    _apiManager = getIt<ApiManager>();
    _clientData = getIt<ClientData>();
    audioPlayer = AudioPlayer(
      audioLoadConfiguration: AudioLoadConfiguration(
        androidLoadControl: AndroidLoadControl(
          minBufferDuration: const Duration(seconds: 20),
          maxBufferDuration: const Duration(seconds: 60),
          bufferForPlaybackDuration: const Duration(milliseconds: 1500),
          bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 3),
          prioritizeTimeOverSizeThresholds: true
        )
      )
    );

    audioPlayer.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          audioPlayer.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[audioPlayer.processingState]!,
        playing: audioPlayer.playing,
        updatePosition: audioPlayer.position,
        bufferedPosition: audioPlayer.bufferedPosition,
        speed: audioPlayer.speed,
        queueIndex: audioPlayer.currentIndex,
      ));
    });

    audioPlayer.sequenceStateStream.listen((index) {
      final currentMediaItem = getCurrentMediaItem();

      mediaItem.add(currentMediaItem);

      if (currentMediaItem != null) {
        currentMediaItemStreamController.add(currentMediaItem);
      }
    });


  }

  final currentMediaItemStreamController = StreamController<MediaItem>.broadcast();
  Stream<MediaItem> get currentMediaItemStream => currentMediaItemStreamController.stream;

  @override Future<void> play() => audioPlayer.play();
  @override Future<void> pause() => audioPlayer.pause();
  @override Future<void> stop() async {
    await audioPlayer.stop();
    return super.stop();
  }
  @override Future<void> skipToNext() => audioPlayer.seekToNext();
  @override Future<void> skipToPrevious() => audioPlayer.seekToPrevious();
  @override Future<void> skipToQueueItem(int index) => audioPlayer.seek(Duration.zero, index: index);
  @override Future<void> seek(Duration position) => audioPlayer.seek(position);

  Future<void> setAudioSources(List<AudioSource> sources, {int? initialIndex}) async {
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
  }

  List<IndexedAudioSource> get sequence => audioPlayer.sequence;

  bool get isPlaying => audioPlayer.playing;

  LoopMode get loopMode => audioPlayer.loopMode;
  set loopMode(LoopMode mode) => audioPlayer.setLoopMode(mode);

  bool get isShuffling => audioPlayer.shuffleModeEnabled;
  set isShuffling(bool value) => audioPlayer.setShuffleModeEnabled(value);

  double get volume => audioPlayer.volume;
  set volume(double value) => audioPlayer.setVolume(value);

  double get speed => audioPlayer.speed;
  set speed(double value) => audioPlayer.setSpeed(value);

  Duration get position => audioPlayer.position;

  bool get hasNext => audioPlayer.hasNext;
  bool get hasPrevious => audioPlayer.hasPrevious;

  Future<void> playPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  void toggleShuffle() {
    audioPlayer.setShuffleModeEnabled(!audioPlayer.shuffleModeEnabled);
  }

  void toggleRepeat() {
    switch (audioPlayer.loopMode) {
      case LoopMode.off:
        audioPlayer.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
  }

  Future<void> playPlaylist(Playlist playlist, bool shuffle) async {
    await audioPlayer.stop();
    final playlistData = await _apiManager.service.getPlaylist(playlist.id);

    if (playlistData.tracks.isEmpty) {
      return;
    }

    await playPlaylistData(playlistData, null, shuffle);
  }

  Future<void> playPlaylistData(PlaylistData data, int? preferredTrackId, bool shuffle) async {

    var tracks = data.tracks.map((i) => i.track).toList();
    final initialIndex = preferredTrackId != null ? tracks.indexWhere((t) => t.id == preferredTrackId) : 0;

    if (tracks.isEmpty) {
      return;
    }

    audioPlayer.setShuffleModeEnabled(shuffle);
    setAudioType(AudioType.playlist, data.playlist.id);

    final mediaToken = await _clientData.getMediaToken();
    final sources = data.tracks.map((track) => _fromTrack(track.track, mediaToken)).toList();
    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
    await play();
    await _apiManager.service.reportPlaylistListen(data.playlist.id);
  }

  Future<void> playAlbum(Album album, bool shuffle) async {
    await audioPlayer.stop();
    final albumData = await _apiManager.service.getAlbum(album.id);

    if (albumData.tracks.isEmpty) {
      return;
    }

    await playAlbumData(albumData, null, shuffle);
  }

  Future<void> playAlbumData(AlbumData data, int? preferredTrackId, bool shuffle) async {
    var tracks = data.tracks;
    final initialIndex = preferredTrackId != null ? tracks.indexWhere((t) => t.id == preferredTrackId) : 0;

    if (tracks.isEmpty) {
      return;
    }

    audioPlayer.setShuffleModeEnabled(shuffle);
    setAudioType(AudioType.album, data.album.id);

    final mediaToken = await _clientData.getMediaToken();
    final sources = data.tracks.map((track) => _fromTrack(track, mediaToken)).toList();
    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
    await play();
    await _apiManager.service.reportAlbumListen(data.album.id);
  }

  Future<void> playMinimalTrack(MinimalTrack track) async {
    final mediaToken = await _clientData.getMediaToken();
    final source = _fromMinimalTrack(track, mediaToken);
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSource(source);
    await play();
  }

  Future<void> playTrack(Track track) async {
    final mediaToken = await _clientData.getMediaToken();
    final source = _fromTrack(track, mediaToken);
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSource(source);
    await play();
  }

  Future<void> playMinimalTrackWithQueue(MinimalTrack track, List<MinimalTrack> queue) async {
    final mediaToken = await _clientData.getMediaToken();
    final sources = queue.map((t) => _fromMinimalTrack(t, mediaToken)).toList();
    final initialIndex = queue.indexWhere((t) => t.id == track.id);
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
    await play();
  }
  
  Future<void> addTrackIdToQueue(int trackId, bool next) async {
    final track = await _apiManager.service.getTrack(trackId);
    return addTrackToQueue(track, next);
  }

  Future<void> addTrackToQueue(Track track, bool next) async {
    final mediaToken = await _clientData.getMediaToken();
    final source = _fromTrack(track, mediaToken);

    if (next && audioPlayer.currentIndex != null) {
      await audioPlayer.insertAudioSource(audioPlayer.currentIndex! + 1, source);
    } else {
      await audioPlayer.addAudioSource(source);
    }

    setAudioType(AudioType.tracks, null);

    if (audioPlayer.sequence.length == 1) {
      await play();
    }
  }

  Future<void> addMinimalTrackToQueue(MinimalTrack track, bool next) async {
    final mediaToken = await _clientData.getMediaToken();
    final source = _fromMinimalTrack(track, mediaToken);

    if (next && audioPlayer.currentIndex != null) {
      await audioPlayer.insertAudioSource(audioPlayer.currentIndex! + 1, source);
    } else {
      await audioPlayer.addAudioSource(source);
    }

    setAudioType(AudioType.tracks, null);

    if (audioPlayer.sequence.length == 1) {
      await play();
    }
  }

  Future<void> addAlbumToQueue(Album album, bool next) async {
    final albumData = await _apiManager.service.getAlbum(album.id);

    if (albumData.tracks.isEmpty) {
      return;
    }

    final mediaToken = await _clientData.getMediaToken();
    final sources = albumData.tracks.map((track) => _fromTrack(track, mediaToken)).toList();

    if (next && audioPlayer.currentIndex != null) {
      await audioPlayer.insertAudioSources(audioPlayer.currentIndex! + 1, sources);
    } else {
      await audioPlayer.addAudioSources(sources);
    }

    if (audioPlayer.sequence.length == sources.length) {
      await play();
    }

    _apiManager.service.reportAlbumListen(album.id);
  }

  Future<void> addPlaylistToQueue(Playlist playlist, bool next) async {
    final playlistData = await _apiManager.service.getPlaylist(playlist.id);

    if (playlistData.tracks.isEmpty) {
      return;
    }

    final mediaToken = await _clientData.getMediaToken();
    final sources = playlistData.tracks.map((track) => _fromTrack(track.track, mediaToken)).toList();

    if (next && audioPlayer.currentIndex != null) {
      await audioPlayer.insertAudioSources(audioPlayer.currentIndex! + 1, sources);
    } else {
      await audioPlayer.addAudioSources(sources);
    }

    if (audioPlayer.sequence.length == sources.length) {
      await play();
    }

    _apiManager.service.reportPlaylistListen(playlist.id);
  }

  MediaItem? getCurrentMediaItem() {
    final current = audioPlayer.sequenceState.currentSource;
    if (current == null) return null;
    final tag = current.tag;
    if (tag is MediaItem) {
      return tag;
    }
    return null;
  }

  AudioSource _fromMinimalTrack(MinimalTrack track, String mediaToken) {
    final url = "${_apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/tracks/${track.id}/stream?mediaToken=$mediaToken";
    final artUrl = "${_apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/tracks/${track.id}/cover?mediaToken=$mediaToken";
    final mi = MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.album.name,
      artist: track.artists.map((a) => a.name).join(", "),
      duration: track.duration == null ? null : Duration(milliseconds: track.duration!),
      artUri: Uri.parse(artUrl),
      artHeaders: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );
    return AudioSource.uri(
        Uri.parse(url),
        tag: mi,
        headers: {
          'Authorization': 'Bearer ${_apiManager.accessToken}',
        }
    );
  }

  AudioSource _fromTrack(Track track, String mediaToken) {
    final url = "${_apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/tracks/${track.id}/stream?mediaToken=$mediaToken";
    final artUrl = "${_apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}/api/tracks/${track.id}/cover?mediaToken=$mediaToken";
    final mi = MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.album.title,
      artist: track.artists.map((a) => a.name).join(", "),
      duration: track.duration == null ? null : Duration(milliseconds: track.duration!),
      artUri: Uri.parse(artUrl),
      artHeaders: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );
    return AudioSource.uri(
      Uri.parse(url),
      tag: mi,
      headers: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );
  }

  static Future<AudioManager> initBackgroundTask() async {

    final settingsManager = getIt<SettingsManager>();

    return await AudioService.init(
        builder: () => AudioManager(),
        config: AudioServiceConfig(
        androidNotificationChannelId: 'wtf.ndu.vibin.channel.audio',
        androidNotificationChannelName: 'Vibin Audio Playback',
        androidStopForegroundOnPause: false,
        androidNotificationIcon: "mipmap/ic_launcher_monochrome",
        notificationColor: settingsManager.get(Settings.accentColor),
      )
    );
  }
}