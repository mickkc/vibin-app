import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
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
  late final SettingsManager _settingsManager;

  CurrentAudioType? _currentAudioType;
  CurrentAudioType? get currentAudioType => _currentAudioType;

  int? _lastIndex;

  // region Init
  
  AudioManager() {
    _apiManager = getIt<ApiManager>();
    _clientData = getIt<ClientData>();
    _settingsManager = getIt<SettingsManager>();

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

    _initPlaybackEvents();
    _initMediaItemEvents();
  }
  
  /// Initializes playback event listeners to update the playback state accordingly.
  void _initPlaybackEvents() {
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
  }
  
  final currentMediaItemStreamController = StreamController<MediaItem?>.broadcast();
  
  /// A stream that emits the current media item whenever it changes or null if there is no current item.
  Stream<MediaItem?> get currentMediaItemStream => currentMediaItemStreamController.stream;
  
  // Initializes media item event listeners to update the current media item accordingly.
  void _initMediaItemEvents() {
    audioPlayer.currentIndexStream.listen((index) {

      if (index == _lastIndex) {
        return;
      }

      final currentMediaItem = getCurrentMediaItem();

      mediaItem.add(currentMediaItem);
      currentMediaItemStreamController.add(currentMediaItem);

      _lastIndex = index;
    });
  }

  /// Initializes the background audio task for audio playback.
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
  
  // endregion

  // region Playback Controls

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

  Future<void> _loadAndPlay() async {
    await audioPlayer.load();
    await play();
  }

  /// Toggles between play and pause states.
  Future<void> playPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  /// Toggles shuffle mode on or off.
  void toggleShuffle() {
    audioPlayer.setShuffleModeEnabled(!audioPlayer.shuffleModeEnabled);
  }

  /// Toggles repeat mode between off, all, and one.
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
  
  // endregion
  
  // region Queue Management

  /// Moves a queue item from oldIndex to newIndex, adjusting the current index as necessary.
  Future<void> moveQueueItem(int oldIndex, int newIndex) async {

    if (oldIndex < 0 || oldIndex >= audioPlayer.sequence.length || audioPlayer.currentIndex == null) {
      return;
    }

    if (newIndex < 0 || newIndex >= audioPlayer.sequence.length) {
      return;
    }

    // Adjust newIndex if moving down the list because all indexes shift down by 1
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final sequence = audioPlayer.sequence;
    final currentIndex = audioPlayer.currentIndex!;

    final newSources = List<AudioSource>.from(sequence);
    final item = newSources.removeAt(oldIndex);
    newSources.insert(newIndex, item);

    int updatedCurrentIndex = currentIndex;
    if (oldIndex == currentIndex) {
      // Same item is being moved - no other adjustments needed
      updatedCurrentIndex = newIndex;
    } else if (oldIndex < currentIndex && newIndex >= currentIndex) {
      // Current item is pushed up - decrement current index
      updatedCurrentIndex -= 1;
    } else if (oldIndex > currentIndex && newIndex <= currentIndex) {
      // Current item is pushed down - increment current index
      updatedCurrentIndex += 1;
    }

    await _rebuild(newSources, currentIndex: updatedCurrentIndex);
  }

  /// Removes the queue item at the specified index, adjusting the current index as necessary.
  @override
  Future<void> removeQueueItemAt(int index) async {
    final sequence = audioPlayer.sequence;
    final currentIndex = audioPlayer.currentIndex ?? 0;

    final newSources = List<AudioSource>.from(sequence);
    newSources.removeAt(index);

    int updatedCurrentIndex = currentIndex;
    if (index < currentIndex) {
      // Current item is pushed up - decrement current index
      updatedCurrentIndex -= 1;
    } else if (index == currentIndex) {
      // Current item is removed - set to next item if possible
      if (newSources.isNotEmpty) {
        updatedCurrentIndex = currentIndex.clamp(0, newSources.length - 1);
      }
      else {
        audioPlayer.stop();
      }
    }

    bool isRemovingCurrentItem = index == currentIndex;

    await _rebuild(newSources, currentIndex: updatedCurrentIndex, position: isRemovingCurrentItem ? Duration.zero : null);

    _queueUpdated();
  }

  /// Called whenever the queue is updated to handle any necessary state changes.
  void _queueUpdated() {
    if (audioPlayer.sequence.isEmpty) {
       setAudioType(AudioType.unspecified, null);
    }
  }
  
  // endregion
  
  // region Sequence Fixes

  /// Inserts a new audio source immediately after the current one.
  /// Rebuilds the entire sequence to fix issues with wrong Indexes.
  /// [newSource] The audio source to insert.
  Future<void> _insertNextAudioSource(AudioSource newSource) async {
    final sequence = audioPlayer.sequence;
    final currentIndex = audioPlayer.currentIndex ?? 0;

    final newSources = List<AudioSource>.from(sequence);

    newSources.insert(
      currentIndex + 1,
      newSource,
    );

    await _rebuild(newSources, currentIndex: currentIndex);
  }

  /// Inserts multiple new audio sources immediately after the current one.
  /// Rebuilds the entire sequence to fix issues with wrong Indexes.
  /// [newSources] The list of audio sources to insert.
  Future<void> _insertNextAudioSources(List<AudioSource> newSources) async {
    final sequence = audioPlayer.sequence;
    final currentIndex = audioPlayer.currentIndex ?? 0;

    final sources = List<AudioSource>.from(sequence);

    sources.insertAll(
      currentIndex + 1,
      newSources,
    );

    await _rebuild(sources, currentIndex: currentIndex);
  }

  /// Rebuilds the audio player's sequence with new sources, preserving the current index and position.
  /// [newSources] The new list of audio sources to set.
  /// [currentIndex] The index to set as the current item after rebuilding. If null, the first item is used.
  /// [position] The position to set for the current item after rebuilding. If null, the current position is preserved.
  Future<void> _rebuild(List<AudioSource> newSources, {int? currentIndex, Duration? position}) async {
    final currentPosition = position ?? audioPlayer.position;
    await audioPlayer.setAudioSources(newSources, initialIndex: currentIndex, initialPosition: currentPosition);
  }
  
  // endregion
  
  // region Play Methods
  
  // region Playlists

  /// Plays the specified playlist, optionally shuffling the tracks.
  /// [playlist] The playlist to play.
  /// [shuffle] Whether to enable shuffle mode (null to not change).
  Future<void> playPlaylist(Playlist playlist, {bool? shuffle}) async {
    await audioPlayer.stop();
    final playlistData = await _apiManager.service.getPlaylist(playlist.id);

    if (playlistData.tracks.isEmpty) {
      return;
    }

    await playPlaylistData(playlistData, shuffle: shuffle);
  }

  /// Plays the specified playlist data, optionally starting from a preferred track and shuffling.
  /// [data] The playlist data to play.
  /// [preferredTrackId] The ID of the track to start playing first, if any.
  /// [shuffle] Whether to enable shuffle mode (null to not change).
  Future<void> playPlaylistData(PlaylistData data, {int? preferredTrackId, bool? shuffle}) async {

    var tracks = data.tracks.map((i) => i.track).toList();
    final initialIndex = preferredTrackId != null ? tracks.indexWhere((t) => t.id == preferredTrackId) : 0;

    if (tracks.isEmpty) {
      return;
    }

    if (shuffle != null) audioPlayer.setShuffleModeEnabled(shuffle);
    setAudioType(AudioType.playlist, data.playlist.id);

    final mediaToken = await _clientData.getMediaToken();
    final sources = await Future.wait(data.tracks.map((track) => _fromTrack(track.track, mediaToken)));
    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
    await _loadAndPlay();
    await _apiManager.service.reportPlaylistListen(data.playlist.id);
  }
  
  // endregion
  
  // region Albums

  /// Plays the specified album, optionally shuffling the tracks.
  /// [album] The album to play.
  /// [shuffle] Whether to enable shuffle mode (null to not change).
  Future<void> playAlbum(Album album, {bool? shuffle}) async {
    await audioPlayer.stop();
    final albumData = await _apiManager.service.getAlbum(album.id);

    if (albumData.tracks.isEmpty) {
      return;
    }

    await playAlbumData(albumData, shuffle: shuffle);
  }

  /// Plays the specified album data, optionally starting from a preferred track and shuffling.
  /// [data] The album data to play.
  /// [preferredTrackId] The ID of the track to start playing first, if any.
  /// [shuffle] Whether to enable shuffle mode (null to not change).
  Future<void> playAlbumData(AlbumData data, {int? preferredTrackId, bool? shuffle}) async {
    var tracks = data.tracks;
    final initialIndex = preferredTrackId != null ? tracks.indexWhere((t) => t.id == preferredTrackId) : 0;

    if (tracks.isEmpty) {
      return;
    }

    if (shuffle != null) audioPlayer.setShuffleModeEnabled(shuffle);
    setAudioType(AudioType.album, data.album.id);

    final mediaToken = await _clientData.getMediaToken();
    final sources = await Future.wait(data.tracks.map((track) => _fromTrack(track, mediaToken)));
    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
    await _loadAndPlay();
    await _apiManager.service.reportAlbumListen(data.album.id);
  }
  
  // endregion
  
  // region Minimal Tracks

  /// Plays the specified minimal track, replacing the current queue.
  /// [track] The minimal track to play.
  Future<void> playMinimalTrack(MinimalTrack track) async {
    final mediaToken = await _clientData.getMediaToken();
    final source = await _fromMinimalTrack(track, mediaToken);
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSource(source);
    await _loadAndPlay();
  }

  /// Plays the specified minimal track within the provided queue of minimal tracks.
  /// [track] The minimal track to play.
  /// [queue] The queue of minimal tracks to play from.
  Future<void> playMinimalTrackWithQueue(MinimalTrack track, List<MinimalTrack> queue) async {
    final mediaToken = await _clientData.getMediaToken();
    final sources = await Future.wait(queue.map((t) => _fromMinimalTrack(t, mediaToken)).toList());
    final initialIndex = queue.indexWhere((t) => t.id == track.id);
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);
    await _loadAndPlay();
  }
  
  // endregion
  
  // region Tracks

  /// Plays the specified track, replacing the current queue.
  /// [track] The track to play.
  Future<void> playTrack(Track track) async {
    final mediaToken = await _clientData.getMediaToken();
    final source = await _fromTrack(track, mediaToken);
    await audioPlayer.stop();

    setAudioType(AudioType.tracks, null);

    await audioPlayer.clearAudioSources();
    await audioPlayer.setAudioSource(source);
    await _loadAndPlay();
  }
  
  // endregion
  
  // endregion
  
  // region Add to Queue Methods

  /// Adds the track with the specified ID to the queue.
  /// [trackId] The ID of the track to add.
  /// [next] Whether to add the track to play next or at the end of the queue.
  Future<void> addTrackIdToQueue(int trackId, bool next) async {
    final track = await _apiManager.service.getTrack(trackId);
    return addTrackToQueue(track, next);
  }

  /// Adds the specified track to the queue.
  /// [track] The track to add.
  /// [next] Whether to add the track to play next or at the end of the queue.
  Future<void> addTrackToQueue(Track track, bool next) async {
    final mediaToken = await _clientData.getMediaToken();
    final source = await _fromTrack(track, mediaToken);

    if (next && audioPlayer.currentIndex != null) {
      await _insertNextAudioSource(source);
    } else {
      await audioPlayer.addAudioSource(source);
    }

    setAudioType(AudioType.tracks, null);

    if (audioPlayer.sequence.length == 1) {
      await _loadAndPlay();
    }
  }

  /// Adds the specified minimal track to the queue.
  /// [track] The minimal track to add.
  /// [next] Whether to add the track to play next or at the end of the queue.
  Future<void> addMinimalTrackToQueue(MinimalTrack track, bool next) async {
    final mediaToken = await _clientData.getMediaToken();
    final source = await _fromMinimalTrack(track, mediaToken);

    if (next && audioPlayer.currentIndex != null) {
      await _insertNextAudioSource(source);
    } else {
      await audioPlayer.addAudioSource(source);
    }

    setAudioType(AudioType.tracks, null);

    if (audioPlayer.sequence.length == 1) {
      await _loadAndPlay();
    }
  }

  /// Adds all tracks from the specified album to the queue.
  /// [album] The album whose tracks to add.
  /// [next] Whether to add the tracks to play next or at the end of the queue.
  Future<void> addAlbumToQueue(Album album, bool next) async {
    final albumData = await _apiManager.service.getAlbum(album.id);

    if (albumData.tracks.isEmpty) {
      return;
    }

    final wasEmpty = audioPlayer.sequence.isEmpty;

    final mediaToken = await _clientData.getMediaToken();
    final sources = await Future.wait(albumData.tracks.map((track) => _fromTrack(track, mediaToken)));

    if (next && audioPlayer.currentIndex != null) {
      await _insertNextAudioSources(sources);
    } else {
      await audioPlayer.addAudioSources(sources);
    }

    if (wasEmpty) {
      setAudioType(AudioType.album, album.id);
      await _loadAndPlay();
    }

    _apiManager.service.reportAlbumListen(album.id);
  }

  /// Adds all tracks from the specified playlist to the queue.
  /// [playlist] The playlist whose tracks to add.
  /// [next] Whether to add the tracks to play next or at the end of the queue.
  Future<void> addPlaylistToQueue(Playlist playlist, bool next) async {
    final playlistData = await _apiManager.service.getPlaylist(playlist.id);

    if (playlistData.tracks.isEmpty) {
      return;
    }

    final wasEmpty = audioPlayer.sequence.isEmpty;

    final mediaToken = await _clientData.getMediaToken();
    final sources = await Future.wait(playlistData.tracks.map((track) => _fromTrack(track.track, mediaToken)));

    if (next && audioPlayer.currentIndex != null) {
      await _insertNextAudioSources(sources);
    } else {
      await audioPlayer.addAudioSources(sources);
    }

    if (wasEmpty) {
      setAudioType(AudioType.playlist, playlist.id);
      await _loadAndPlay();
    }

    _apiManager.service.reportPlaylistListen(playlist.id);
  }
  
  // endregion
  
  // region Helpers

  void setAudioType(AudioType type, int? id) {
    _currentAudioType = CurrentAudioType(audioType: type, id: id);
  }

  /// Gets the current media item being played, or null if there is none.
  MediaItem? getCurrentMediaItem() {
    final current = audioPlayer.sequenceState.currentSource;
    if (current == null) return null;
    final tag = current.tag;
    if (tag is MediaItem) {
      return tag;
    }
    return null;
  }
  
  // endregion
  
  // region AudioSource Builders

  Future<AudioSource> _fromMinimalTrack(MinimalTrack track, String mediaToken) async {

    final trackUri = _getStreamUrl(track.id, mediaToken);
    final artUri = await _getCoverUri(track.id, mediaToken);

    final mi = MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.album.name,
      artist: track.artists.map((a) => a.name).join(", "),
      duration: track.duration == null ? null : Duration(milliseconds: track.duration!),
      artUri: artUri,
      artHeaders: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );

    return AudioSource.uri(
        trackUri,
        tag: mi,
        headers: {
          'Authorization': 'Bearer ${_apiManager.accessToken}',
        }
    );
  }

  Future<AudioSource> _fromTrack(Track track, String mediaToken) async {

    final trackUri = _getStreamUrl(track.id, mediaToken);
    final artUri = await _getCoverUri(track.id, mediaToken);

    final mi = MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.album.title,
      artist: track.artists.map((a) => a.name).join(", "),
      duration: track.duration == null ? null : Duration(milliseconds: track.duration!),
      artUri: artUri,
      artHeaders: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );

    return AudioSource.uri(
      trackUri,
      tag: mi,
      headers: {
        'Authorization': 'Bearer ${_apiManager.accessToken}',
      }
    );
  }

  Future<Uri> _getCoverUri(int trackId, String mediaToken) async {
    
    if (_settingsManager.get(Settings.embedImagesAsBase64)) {
      try {
        final bytes = await _apiManager.service.getTrackCover(
            trackId, _settingsManager.get(Settings.metadataImageSize).qualityParam
        );
        if (bytes.data.isNotEmpty) {
          return Uri.dataFromBytes(bytes.data, mimeType: "image/jpeg");
        }
      }
      catch (e) {
        log("Failed to fetch and embed cover image for track $trackId: $e", error: e, level: Level.error.value);
      }
    }
    
    return Uri.parse(
        "${_apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}"
            "/api/tracks/$trackId/cover"
            "?mediaToken=$mediaToken"
            "&quality=${_settingsManager.get(Settings.metadataImageSize).qualityParam}");
  }

  Uri _getStreamUrl(int trackId, String mediaToken) {
    return Uri.parse(
        "${_apiManager.baseUrl.replaceAll(RegExp(r'/+$'), '')}"
            "/api/tracks/$trackId/stream"
            "?mediaToken=$mediaToken");
  }
  
  // endregion
}